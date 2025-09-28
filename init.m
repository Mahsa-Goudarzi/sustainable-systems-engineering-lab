%% Greenhouse Model Parameters

clc
clear 
%1 hour of sampletime
sampletime=1;  %60*60*1;

% ---------------- Initial Values ----------------
T_init = 20;     % initial temperature [°C]
H_init = 70;     % initial humidity [%RH]
W_init = 65;     % initial soil moisture [% Volume of water/Volume of soil]
C_init = 930;    % initial CO2 [ppm]

% ---------------- Temperature ----------------
a_T = 1/12000;           % [°C/J] Heating/cooling efficiency
b_T = 1/600;             % [1/s] Heat transfer coefficient
c_T = 1/12000;           % [°C*m^2/J] Solar gain efficiency

% ---------------- Humidity ----------------
a_H = 1;            % [%RH/m^3] Irrigation coefficient (humidity effect)
alpha = 2e-5;       % [kg/s per %soil moisture] Transpiration rate factor
b_H = 2;            % [%RH/kg] Transpiration coefficient
c_H = 3e-4;         % [1/s] Humidity exchange coefficient
d_H = 12;           % [%RH/kg] Humidifier efficiency

% ---------------- Soil Moisture ----------------
a_W = 5;            % [percent/m^3] Irrigation coefficient (soil effect)
b_W = 8.3e-6;       % [1/s] soil moisture coefficient
c_W = 1;            % [1/kg] Plant uptake coefficient
beta = 2.3e-5;      % [kg/s] water uptake rate coefficient
d_W = 1;            % [1/kg] Drainage coefficient
nu = 1.4e-5;        % [kg/s] drainage rate coefficient

% ---------------- CO2 ----------------
a_C = 1000;       % [ppm/kg] CO2 injection efficiency
b_C = 17;         % [ppm/kg] CO2 uptake coefficient
gamma = 0.002;    % [kg/ppm.s] plant uptake coefficient
c_C = 2.8e-8;     % [1/s] CO2 leakage exchange rate
d_C = 5.6e-2;     % [1/s] Ventilation exchange coefficient

% ---------------- Biomass ----------------
a_B = 3.3e-6;          % [kg/(°C*s)] Temperature-related growth coefficient
b_B = 5.0e-6;          % [kg/(%RH*s)] Humidity-related growth coefficient
c_B = 7.0e-9;          % [kg/(ppm*s)] CO2-related growth coefficient
d_B = 1.8e-7;          % [kg*m^2/(W*s)] Light-related growth coefficient
e_B = 3.1e-7;          % [1/s] Biomass decay rate

% ---------------- Optimal Conditions (for reference) ----------------
tempo=[0:60*60:24*60*60]';

% T_opt = between 20-24
T_opt = 22;

T_outside = [18; 18; 20; 22; 22; 22; 24; 24; 25; 25; 26; 28; 30; 30; 30; 32; 34; 35; 36; 33; 30; 26; 24; 22; 17];
T_ambient2sim=[tempo T_outside];

% H_opt = Optimal Relative Humidity: 60–85% 
H_ReferencePoint = 75;

H_outside= [90; 91; 88; 84; 83; 82; 78; 76; 72; 70; 68; 60; 52; 50; 48; 45; 42; 40; 38; 43; 50; 58; 65; 70; 85];
H_ambient2sim=[tempo H_outside];

% W_opt = 60 to 80 % volumetric
W_ReferencePoint = 70;

% C_opt = 800 - 1000 ppm
C_ReferencePoint = 900;

C_outside = [450; 455; 440; 430; 420; 415; 410; 405; 400; 398; 395; 392; 390; 388; 390; 393; 395; 400; 405; 410; 420; 430; 440; 445; 450];
C_ambient2sim=[tempo C_outside];

% ---------------- Other necessary data ----------------
IrrigationRate = 0.0008; %[m^3/s] 

Q_solar = [0; 0; 0; 0; 0; 0; 50; 150; 300; 500; 650; 800; 900; 950; 900; 800; 650; 400; 100; 0; 0; 0; 0; 0; 0]; %[W/m^2]
Q_solar2sim=[tempo Q_solar];

% water tank cross section area (m^2)
A = 1;

%% Calculations

% Total irrigation (m^3)
total_irrigation = trapz(irrigation2out.Time, irrigation2out.Data);
fprintf('Water Used (in m^3): %.4f\n', total_irrigation);

% rain (m^3)
recycled_water = trapz(rain2out.Time, rain2out.Data);
fprintf('Recycled water (in m^3): %.4f\n', recycled_water);

% bimass yield
biomass_yield = Biomass.Data(end);
fprintf('Biomass yield (in kg): %.4f\n', biomass_yield);

% Energy used
heater_energy = trapz(Q_heater2out.Time, abs(Q_heater2out.Data))/(3.6e+06); % in [kWh]
humidifier_energy = 2; %2 kWh per 24 hours
ventilator_energy = 2; %2 kWh per 24 hours

co2inj_energy_rate = 80; %between 80 kWh and 120 kWh per tonne of CO2
tonne_CO2 = trapz(injector2out.Time, injector2out.Data)/1000;
co2_inj_energy = co2inj_energy_rate * tonne_CO2; % in [kWh]

total_energy_used = heater_energy + humidifier_energy + ventilator_energy + co2_inj_energy;
fprintf('Energy Used (in kWh): %.4f\n', total_energy_used);

% water saving
fprintf('Water saving: %.4f\n', recycled_water/total_irrigation);

% Energy Efficiency
fprintf('Energy Efficiency: %.4f\n', biomass_yield/total_energy_used);