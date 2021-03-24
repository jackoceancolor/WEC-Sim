function writeBlocksFromInput(blockHandle,type,inputFile)
% Load Parameters from Input File to Masked Subsystem 
% CAN NOT override any parameter values that have not been
% applied by the user in the dialog box.

% 'type' refers to the WEC-Sim block type being used:
% type = 0, Global Reference Frame
% type = 1, Body
% type = 2, PTO
% type = 3, Constraint
% type = 4, Mooring
% type = 5, MoorDyn

run(inputFile);

% Get struct of block's mask variables
values = get_param(blockHandle,'MaskValues');                % Cell array containing all Masked Parameter values
names = get_param(blockHandle,'MaskNames');                  % Cell array containing all Masked Parameter names
maskVars = struct();
for i=1:length(names)
    maskVars.(names{i}) = values{i};
end

% Read relevant class data into the block mask
switch type
    
    case 0
    % Simulation Data
    maskVars.mode = simu.mode;                                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
    maskVars.explorer = simu.explorer;                           % Turn SimMechanics Explorer (on/off)
    maskVars.startTime = simu.startTime;                         % Simulation Start Time [s]
    maskVars.rampTime = simu.rampTime;                           % Wave Ramp Time [s]
    maskVars.endTime = simu.endTime;                             % Simulation End Time [s]
    maskVars.solver = simu.solver;                               % simu.solver = 'ode4' for fixed step & simu.solver = 'ode45' for variable step 
    maskVars.dt = simu.dt;                                       % Simulation time-step [s]
    maskVars.CITime = simu.CITime;                               % Specify CI Time [s]
    if simu.ssCalc == 1                                          % Check if state-space is enabled
        maskVars.ssCalc = 'on';
    else
        maskVars.ssCalc = 'off';
    end

    % Wave Information
    maskVars.WaveClass = waves.type;                             % Initialize Wave Class and Specify Type                                           
    maskVars.H = waves.H;                                        % Wave Height [m]
    maskVars.T = waves.T;                                        % Wave Period [s]
    maskVars.waveDir = waves.waveDir;                            % Wave Directionality [deg]
    maskVars.waveSpread = waves.waveSpread;                      % Wave Directional Spreading [%]
    maskVars.spectrumType = waves.spectrumType;                  % Specify Wave Spectrum Type
    maskVars.freqDisc = waves.freqDisc;                          % Uses 'EqualEnergy' bins (default) 
    maskVars.phaseSeed = waves.phaseSeed;                        % Phase is seeded so eta is the same
    maskVars.spectrumDataFile = waves.spectrumDataFile;          % Name of User-Defined Spectrum File [:,2] = [f, Sf]
    maskVars.etaDataFile = waves.etaDataFile;                    % Name of User-Defined Time-Series File [:,2] = [time, eta]

    case 1
    % Body Data
    % Float
    tmp = string(maskVars.body);
    num = str2num(extractBetween(tmp,strfind(tmp,'('),strfind(tmp,')'),'Boundaries','Exclusive'));
    maskVars.h5File = body(num).h5File;                          % Create the body(1) Variable, Set Location of Hydrodynamic Data File and Body Number Within this File.   
    maskVars.geometryFile = body(num).geometryFile;              % Location of Geomtry File
    maskVars.mass = body(num).mass;                              % Body Mass
    maskVars.momOfInertia = body(num).momOfInertia;              % Moment of Inertia [kg*m^2]  
    maskVars.nhBody = body(num).nhBody;
    maskVars.flexHydroBody = body(num).flexHydroBody;
    maskVars.cg = body(num).cg;
    maskVars.cb = body(num).cb;
    maskVars.dof = body(num).dof;
    maskVars.dispVol = body(num).dispVol;
    maskVars.initLinDisp = body(num).initDisp.initLinDisp;
    maskVars.initAngularDispAxis = body(num).initDisp.initAngularDispAxis;
    maskVars.initAngularDispAngle = body(num).initDisp.initAngularDispAngle;
    maskVars.cd = body(num).morisonElement.cd;
    maskVars.ca = body(num).morisonElement.ca;
    maskVars.characteristicArea = body(num).morisonElement.characteristicArea;
    maskVars.VME = body(num).morisonElement.VME;
    maskVars.rgME = body(num).morisonElement.rgME;
    maskVars.z = body(num).morisonElement.z;
    
    
    case 2
    % PTO Parameters
    tmp = string(maskVars.pto);
    num = str2num(extractBetween(tmp,strfind(tmp,'('),strfind(tmp,')'),'Boundaries','Exclusive'));
    maskVars.loc = pto(num).loc;                                   % PTO Location [m]
    maskVars.k = pto(num).k;                                       % PTO Stiffness [N/m]
    maskVars.c = pto(num).c;                                       % PTO Damping [N/(m/s)]
    
    case 3
    % Constraint Parameters
    tmp = string(maskVars.constraint);
    num = str2num(extractBetween(tmp,strfind(tmp,'('),strfind(tmp,')'),'Boundaries','Exclusive'));
    maskVars.loc = constraint(num).loc;                            % Constraint Location [m]
    
    case 4
    % Mooring Parameters
    tmp = string(maskVars.mooring);
    num = str2num(extractBetween(tmp,strfind(tmp,'('),strfind(tmp,')'),'Boundaries','Exclusive'));
    maskVars.ref = mooring(num).ref;
    maskVars.k = mooring(num).k;
    maskVars.c = mooring(num).c;
    
    case 5
    % MoorDyn Parameters
    tmp = string(maskVars.mooring);
    num = str2num(extractBetween(tmp,strfind(tmp,'('),strfind(tmp,')'),'Boundaries','Exclusive'));
    maskVars.ref = mooring(num).ref;
    maskVars.moorDynLines = mooring(num).moorDynLines;
    maskVars.moorDynNodes = mooring(num).moorDynNodes;
end

% Update all values in string format
for i = 1:length(values)
    values{i,1} = num2str(maskVars.(names{i,1}));
end; clear i;

% Load Masked Subsystem with updated values
set_param(blockHandle,'MaskValues',values);

% Clear variables from workspace
clear maskVars values names simu waves body constraint pto mooring

if type==0
    waveClassCallback(blockHandle);
end