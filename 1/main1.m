% Parameters
n_particles = 30;
n_vehicles = 20;
n_timeslots = 96;
n_buses = 33;
slot_duration = 0.25; % hourly timeslots
max_iter = 50;

p_base = 1.25; % KW 
max_station_capacity = 100; % KW
charging_efficiency = 0.9;

% Generating compatible arrays
%max_battery_capacity = datasample([75, 80.7, 60, 64.8, 46.3, 74, 85, 70.5, 64, 58], n_vehicles, 'Replace', true)'; % kWh
%charging_power = datasample([11, 3.3, 7.4], n_vehicles, 'Replace', true)'; % KW

soc_final = 0.9 * ones(n_vehicles, 1);
%soc_initial = 0.2 + (0.6 - 0.2) * rand(n_vehicles, 1);

% Arrival times within 24 hours
%arrival_times = randi([1, 84], n_vehicles, 1);

% Calculate charging times
%charging_times = ((soc_final - soc_initial) .* max_battery_capacity) ./ (charging_efficiency .* charging_power .* slot_duration);

%Calculate Departure times
%departure_times = zeros(n_vehicles, 1);
%for i = 1:n_vehicles
%    min_departure_time = ceil(arrival_times(i) + charging_times(i));
%    if min_departure_time > n_timeslots
%            min_departure_time = n_timeslots;
%    end
%    departure_times(i) = randi([min_departure_time, n_timeslots]);
%end

max_battery_capacity=[58
46.3
80.7
46.3
64.8
85
75
70.5
80.7
60
75
70.5
46.3
85
58
75
64
60
64.8
85];

charging_power=[7.4
11
3.3
3.3
3.3
3.3
7.4
3.3
11
11
3.3
7.4
7.4
11
3.3
7.4
7.4
3.3
3.3
11];

soc_initial=[0.580393557
0.384444874
0.491731243
0.442006092
0.537017933
0.420937183
0.52471429
0.412007922
0.316710155
0.342076806
0.253554204
0.302095797
0.568533813
0.47319819
0.453462743
0.255093646
0.479468619
0.425832288
0.460522812
0.552175695
];

arrival_times=[7
79
31
7
71
51
8
6
40
51
74
10
10
2
65
8
68
47
72
14
];

charging_times=[11.13343764
9.644526199
44.37345273
28.5590814
31.67843491
54.84220803
16.9047617
46.33460136
19.01878405
13.52541077
65.29755512
25.31666443
9.217348016
14.65783994
34.8810248
29.04983575
16.16456961
38.31658276
38.35437273
11.94548119
];

departure_times=[19
89
93
68
96
96
48
58
92
82
96
82
33
39
96
94
94
90
96
28
];

fprintf('max_station_capacity\n')
disp(max_station_capacity)
fprintf('p_base\n')
disp(p_base)
fprintf('max_battery_capacity\n')
disp(max_battery_capacity)
fprintf('charging_power\n')
disp(charging_power)
fprintf('charging_times\n')
disp(charging_times)
fprintf('soc_initial\n')
disp(soc_initial)
fprintf('soc_final\n')
disp(soc_final)
fprintf('arrival_times\n')
disp(arrival_times)


% Running BPSO
[ load2, price2 ] = unscheduled(n_vehicles, n_timeslots, arrival_times, charging_times, charging_power, slot_duration, p_base);
[ best_position, best_score, load1, price1 ] = binary_pso1(n_particles, n_vehicles, n_timeslots, max_iter, arrival_times, departure_times, charging_power, max_station_capacity, soc_initial, soc_final, max_battery_capacity, slot_duration, p_base, price2);


Vehicles = zeros(n_vehicles,1);
for i = 1:n_vehicles 
    Vehicles(i) = i; 
end

%Header update
Header1 = {'Vehicles', 'max_battery_capacity', 'charging_power', 'soc_initial', 'soc_final', 'arrival_times', 'charging_times', 'departure_times', 'positions'};
Header2 = {'Scheduled cost', 'Unscheduled Cost', 'Cost reduced'};
best_position1 = reshape(best_position, [ n_vehicles, n_timeslots]);

% Write data to Excel
filename = 'C:\Users\adith\Desktop\New folder\output_data.xlsx';

% Load the existing data to determine the next empty row
if isfile(filename)
    [~, ~, raw1] = xlsread(filename, 'Sheet1');
    next_row1 = size(raw1, 1) + 1;
    [~, ~, raw2] = xlsread(filename, 'Sheet2');
    next_row2 = size(raw2, 1) + 1;
else
    next_row1 = 2; % Start after the header if file does not exist
    writecell(Header1, filename, 'Sheet', 1, 'Range', 'A1');
    next_row2 = 2; % Start after the header if file does not exist
    writecell(Header2, filename, 'Sheet', 2, 'Range', 'A1');
end

% Write data starting from the next empty row
writematrix(Vehicles, filename, 'Sheet', 1, 'Range', ['A' num2str(next_row1)]);
writematrix(max_battery_capacity, filename, 'Sheet', 1, 'Range', ['B' num2str(next_row1)]);
writematrix(charging_power, filename, 'Sheet', 1, 'Range', ['C' num2str(next_row1)]);
writematrix(soc_initial, filename, 'Sheet', 1, 'Range', ['D' num2str(next_row1)]);
writematrix(soc_final, filename, 'Sheet', 1, 'Range', ['E' num2str(next_row1)]);
writematrix(arrival_times, filename, 'Sheet', 1, 'Range', ['F' num2str(next_row1)]);
writematrix(charging_times, filename, 'Sheet', 1, 'Range', ['G' num2str(next_row1)]);
writematrix(departure_times, filename, 'Sheet', 1, 'Range', ['H' num2str(next_row1)]);
writematrix(best_position1, filename, 'Sheet', 1, 'Range', ['I' num2str(next_row1)]);
writematrix(price1, filename, 'Sheet', 2, 'Range', ['A' num2str(next_row2)]);
writematrix(price2, filename, 'Sheet', 2, 'Range', ['B' num2str(next_row2)]);
writematrix(price2-price1, filename, 'Sheet', 2, 'Range', ['C' num2str(next_row2)]);

disp('Best Position:');
disp(reshape(best_position, [n_vehicles, n_timeslots]));
disp('Best Score:');
disp(best_score);
disp('Scheduled cost:')
disp(price1)
disp('UnScheduled cost:')
disp(price2)
disp('Cost Reduced:');
disp( price2 - price1);

vol_data1 = zeros(n_buses, n_timeslots);
vol_data2 = zeros(n_buses, n_timeslots);

for t = 1:n_timeslots
    [V1, power_loss1] = bfs1(load1(t));
    [V2, power_loss2] = bfs1(load2(t));
    vol_data1(:, t) = abs(V1);
    vol_data2(:, t) = abs(V2);
    power_loss1_all(:,t) = power_loss1;
    power_loss2_all(:,t) = power_loss2;
end

figure(1);
[surf_timeslots, surf_buses] = meshgrid(1:n_timeslots, 1:n_buses);
surf(surf_timeslots, surf_buses, vol_data1);
xlabel('Time Slots', 'FontSize', 16,'FontWeight','bold');
ylabel('Buses', 'FontSize', 16,'FontWeight','bold');
zlabel('Voltage Magnitude (p.u.)', 'FontSize', 16,'FontWeight','bold');
ax = gca;
ax.FontSize = 16;
ax.FontWeight = "bold";
title('Voltage Magnitude Across Buses and Time Slots (Scheduled)');
grid on;

figure(6);
% Plot vol_data2 as bar graph
surf(surf_timeslots, surf_buses, vol_data2);
xlabel('Time Slots', 'FontSize', 16,'FontWeight','bold');
ylabel('Buses', 'FontSize', 16,'FontWeight','bold');
zlabel('Voltage Magnitude (p.u.)', 'FontSize', 16,'FontWeight','bold');
ax = gca;
ax.FontSize = 16;
ax.FontWeight = "bold";
title('Voltage Magnitude Across Buses and Time Slots (Unscheduled)');
grid on;


figure(2);
hold on;
% Combine scheduled and unscheduled power loss data for plotting
power_loss_all = [power_loss1_all; power_loss2_all];

% Create time slot labels (optional, adjust numbering if needed)
time_slot_labels = 1:n_timeslots;
bar(time_slot_labels, power_loss_all);
xlabel('Time Slots');
ylabel('Power Loss (KW)');
legend('Scheduled', 'Unscheduled');
title('Power Loss Across All Time Slots');
hold off;

figure(3);
hold on;
plot(1:n_timeslots, load1, 'r-*');
plot(1:n_timeslots, load2, 'b-o');
plot(1:n_timeslots, repmat(max_station_capacity, 1, n_timeslots), 'k-');
ylabel('Load(KW)');
xlabel('Timeslot');
title('Station load');
hold off;
