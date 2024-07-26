function [best_position, best_score, load, price1] = binary_pso1(n_particles, n_vehicles, n_timeslots, max_iter, arrival_times, departure_times, charging_power, max_station_capacity, soc_initial, soc_final, max_battery_capacity, slot_duration, p_base, price2)
    
    %Number of dimensions
    n_dimensions = n_vehicles * n_timeslots;
    
    % Initialize particle positions (0, 1) and velocities (continuous)
    positions = randi([0, 1], n_particles, n_dimensions);
    velocities = rand(n_particles, n_dimensions) * 2 - 1;  % Velocities in range [-1, 1]
    
    for i = 1:n_particles
        for v = 1:n_vehicles
            for t = 1:n_timeslots
                if t < arrival_times(v,1) || t > departure_times(v,1)
                    positions(i, (t - 1)*n_vehicles + v) = 0;
                end
            end
        end
    end

    % Initialize personal and global bests
    personal_best_positions = positions;
    personal_best_scores = inf(n_particles, 1);
    global_best_score = inf;
    global_best_position = positions(1, :);
    

    for i = 1:n_particles
        [ fitness, load, price1] = objective_function1(positions(i, :), arrival_times, departure_times, charging_power, max_station_capacity, n_timeslots, n_vehicles, p_base, soc_initial, soc_final, max_battery_capacity, slot_duration, price2);
        personal_best_scores(i) = fitness;
        if fitness < global_best_score
            global_best_score = fitness;
            global_best_position = positions(i, :);
        end
    end
    
    % Parameters
    w = 0.5;  % Inertia weight
    c1 = 1.5; % Cognitive parameter
    c2 = 1.5; % Social parameter
    
    % Main optimization loop
    for iter = 1:max_iter
        for i = 1:n_particles
            % Update velocity
            r1 = rand(1, n_dimensions);
            r2 = rand(1, n_dimensions);
            cognitive_velocity = c1 * r1 .* (personal_best_positions(i, :) - positions(i, :));
            social_velocity = c2 * r2 .* (global_best_position - positions(i, :));
            velocities(i, :) = w * velocities(i, :) + cognitive_velocity + social_velocity;
            
            % Update position using sigmoid function
            sigmoid_v = 1 ./ (1 + exp(-velocities(i, :)));
            positions(i, :) = (rand(1, n_dimensions) < sigmoid_v);
            
            for v = 1:n_vehicles
                for t = 1:n_timeslots
                    if t < arrival_times(v,1) || t > departure_times(v,1)
                        positions(i, (t - 1)*n_vehicles + v) = 0;
                    end
                end
            end
            
            % Evaluate fitness
            [ fitness, load, price1 ] = objective_function1(positions(i, :), arrival_times, departure_times, charging_power, max_station_capacity, n_timeslots, n_vehicles, p_base, soc_initial, soc_final, max_battery_capacity, slot_duration, price2);
            if fitness < personal_best_scores(i)
                personal_best_scores(i) = fitness;
                personal_best_positions(i, :) = positions(i, :);
            end
            
            if fitness < global_best_score
                global_best_score = fitness;
                global_best_position = positions(i, :);
            end
        end
    end
    
    
    best_position = global_best_position;
    best_score = global_best_score;
end