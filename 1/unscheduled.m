function [ station_load, cost ] = unscheduled(n_vehicles, n_timeslots, arrival_times, charging_times, charging_power, slot_duration, p_base)
    
    %Initialize the table
    schedule(n_vehicles,n_timeslots) = 0;
    
    for i = 1:n_vehicles
        for t = arrival_times(i,1):ceil(arrival_times(i,1) + charging_times(i,1))
            schedule( i, t ) = 1;
        end
    end

    station_load = zeros(1, n_timeslots);
    cost = 0;
    k1 = 0.026; % $
    k2 = 0.001*[ 6.62400;  6.62400;  6.62400;  6.62400;
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

    for t = 1:n_timeslots
        total_load = 0;
        load = charging_power .* schedule(:, t);
        for m= 1:size(load)
            total_load = total_load + load(m);
        end
        price = k1 + (k2(t) * (total_load + p_base - (pv_eff*g(t)*area_pv/1000))*slot_duration);
        station_load(t) = total_load + p_base;
        cost = cost + price;
    end

    figure(4);
    t=1:n_timeslots;
    plot(t,g,'k-*');
    xticks(0:4:n_timeslots); % Set the ticks at every 4 timeslots (or adjust as needed)
    xticklabels(arrayfun(@(x) sprintf('%02d:00', x), 0:23, 'UniformOutput', false));
    ylabel("Irradiation(W/m^2)");
    xlabel("Time");
    title("Solar Irradiation per day")
    
    figure(5);
    plot(t,k2+k1,'k-*');
    ylabel("Price ($/KW)", 'FontSize', 16,'FontWeight','bold');
    xlabel("Timeslots", 'FontSize', 16,'FontWeight','bold');
    ax = gca;
    ax.FontSize = 16;
    ax.FontWeight = "bold";
    xticks(0:4:n_timeslots); % Set the ticks at every 4 timeslots (or adjust as needed)
    xticklabels(arrayfun(@(x) sprintf('%02d:00', x), 0:23, 'UniformOutput', false));
    xlim([1, n_timeslots]); % Set x-axis limits to stop after the last hour

