function [ score, station_load, cost] = objective_function1(position, arrival_times, departure_times, charging_power, max_station_capacity, n_timeslots, n_vehicles, p_base, soc_initial, soc_final, max_battery_capacity, slot_duration, price2)
    positions = reshape(position, [n_vehicles, n_timeslots]);
    
    station_load = zeros(1, n_timeslots);
    cost = 0;
    k1 = 0.0026; % $
    k2 = 0.001*[6.62400;  6.62400;  6.62400;  6.62400;
                 7.16422;  7.16422;  7.16422;  7.16422;
                 6.74538;  6.74538;  6.74538;  6.74538;
                 6.95775;  6.95775;  6.95775;  6.95775;
                 9.27288;  9.27288;  9.27288;  9.27288;
                15.20519; 15.20519; 15.20519; 15.20519;
                28.42923; 28.42923; 28.42923; 28.42923;
                35.61738; 35.61738; 35.61738; 35.61738;
                49.11844; 49.11844; 49.11844; 49.11844;
                53.55456; 53.55456; 53.55456; 53.55456;
                42.21711; 42.21711; 42.21711; 42.21711;
                34.37511; 34.37511; 34.37511; 34.37511;
                30.91175; 30.91175; 30.91175; 30.91175;
                35.29838; 35.29838; 35.29838; 35.29838;
                30.90443; 30.90443; 30.90443; 30.90443;
                30.20166; 30.20166; 30.20166; 30.20166;
                29.55767; 29.55767; 29.55767; 29.55767;
                32.56343; 32.56343; 32.56343; 32.56343;
                34.10226; 34.10226; 34.10226; 34.10226;
                28.94635; 28.94635; 28.94635; 28.94635;
                16.28807; 16.28807; 16.28807; 16.28807;
                11.69811; 11.69811; 11.69811; 11.69811;
                11.92794; 11.92794; 11.92794; 11.92794;
                 6.78573;  6.78573;  6.78573;  6.78573]; % $/KWh   

    g = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;39;54;78;155;196;237;276;313;348;381;410;437;460;480;496;509;518;523;524;521;515;505;491;474;452;428;400;370;336;300;262;222;181;140;99;61;15;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0]; %W/m2
    area_pv = 10; %m2
    pv_eff = 0.2;

    penalty = 0;
    factor = 1000;
    
    
    % Calculate cost
    for t = 1:n_timeslots
        total_load = 0;
        for v = 1:n_vehicles
            if t < arrival_times(v,1) || t > departure_times(v,1)
                if positions(v, t) > 0  % If vehicle is charging outside of arrival and departure times
                    penalty = penalty + factor*2;  % Add penalty
                end 
                position(v, t) = 0;  % Set charging power to 0 outside of arrival and departure times
            end
        end
        load = charging_power .* positions(:, t);
        for m= 1:size(load)
            total_load = total_load + load(m);
        end
        price = k1 + (k2(t) * (total_load + p_base - ( pv_eff*g(t)*area_pv/1000) )*slot_duration);
        station_load(t) = total_load + p_base;
        cost = cost + price;
    end

    % Penalty for insufficient energy
    for i = 1:n_vehicles
        soc = soc_initial(i,1);
        for t = arrival_times(i,1):departure_times(i,1)
            soc = soc + ( positions(i, t) * charging_power(i) * slot_duration) / max_battery_capacity(i);
        end
        if soc < soc_final(i,1)
            penalty = penalty + (factor*2)*(soc_final(i,1) - soc)^2;
        end
    end

    % Penalty for exceeding charging capacity
    for t = 1:n_timeslots
        total_power = p_base + sum( charging_power .* positions(:, t));
        if total_power > max_station_capacity
            penalty = penalty + factor*(total_power - max_station_capacity)^2;
        end
    end

    % Penalty for higher price
    if cost >= price2
        penalty = penalty + factor*(cost - price2)^2;
    end

    score = cost + penalty;
end
