%% Explanation
% rr contains the reading values
% targetsRR contains annoted data about actual fibrilation or PAF episodes
% detectRR contains detection data from the algorithm that is suppossed to
% detect PAF episodes
% Either rhythm or rhythm and morphology analysis for the detection
% AF is when the heart is getting out of rhythm due to scattered electrical
% signals in the upper chambers of the heart

%% Training set 1
clear
load("afdb_1.mat")
figure
ax1 = subplot(211)
plot(rr) % rr interval
title('RR-interval, Training set 1')
ylabel('Time difference')
xlabel('Sample meassure')
% subplot(312)
% plot(qrs) % qrsinterval

w_size = 8 % arbitrary window size, beats

tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr)

% t=0:1/Fs:length(qrs)/Fs-1/Fs; % skapar tidsvektor mellan 0 och (length(ekg)/Fs-1/Fs), stegintervall: 1/Fs mellan varje punkt, i sekunder
% subplot(313)
% plot(t, qrs)

% % plotta och visa när AF inträffar

ax2 = subplot(212)
plot(targetsRR,'Color',[0.5 0 0.8], 'LineWidth',2)
title('AF classification')
xlabel('Sample meassure')

linkaxes([ax1 ax2], 'x')


%% Sliding window
sum_bhat = 0;
for j = 1:1:length(rr)-w_size
    H = 0; % Heavyside step function
    similarity = -1; % initial value
    for i = j:1:(j + w_size - 1)
        %detection step of the sliding window
        % window(i), where window is a function based on w_size of the
        % rr-interval
        
        window = rr(j:j+w_size-1);
        w_mean = mean(window);
        w_std = std(window);
        r = w_std*0.2; % placeholder for now, to be replaced with adaptive deviation
        

        if j<2
            % nothing happens
        else
            similarity = abs(old_window-window); % TODO borde vara max-norm men osäker på vad det är + implementeringen
        end

        old_window = window; % saves the window
%         disp('here')
    
         
        if r - similarity >= 0
            H = H + 1;
        end    
    end
    avg_simsub_j = H / length(rr); % B_i hat of m and r in the litterature
    sum_bhat = sum_bhat + avg_simsub_j; % accumulates a sum for sum_bhat 
end
bhat_actual = sum_bhat / (length(rr)-w_size) % TODO kan vara fel storlek, kontrolera iom index inte börjar på 0

% om bhat_actual istället på ngt vis görs om till en vektor?
% Isampen = -ln(B(m+1,r)/B(m,r))

%% TEST FÖR ISSAMPEN TRAININGSET 1
clear
load("afdb_1.mat")
% figure
% subplot(311)
% plot(rr) % rr interval
% subplot(312)
% plot(qrs) % qrsinterval

w_size = 30 % arbitrary window size, beats
alfa = 0.05 % learning rate

tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr)
data_size = length(rr)


sum_bhat = 0;
H_sum = 0;
similarity = -1;
bhat_actual = 0;
bhat_tot = 0;
Issampen_moment = 0;
Issampen = 0;
prior_b = 0;
w_mean = 0;
for i = 1:data_size-w_size-1 %kontrollera w_size-1 ifall rätt iom summa N-2
    H = 0; % Heavyside step function
    for j =i:1:w_size
        %detection step of the sliding window
        % window(i), where window is a function based on w_size of the
        % rr-interval
        
        window = rr(i:i+w_size-1)
        w_mean = mean(window);
        w_std = std(window);
        r = w_std*0.4; % placeholder for now, to be replaced with adaptive deviation

        if i<2
            % nothing happens
        else
            similarity = abs(old_window-window); % TODO borde vara max-norm men osäker på vad det är + implementeringen
        end

        old_window = window; % saves the window
        if r - similarity >=0
            H = H + 1;
        end

        if i <=1
        %inget händer
        else 
            b_prior = bhat_actual; % saves prior b, if we are at large enough iteration step
        end
        H_sum = H_sum + H;
        bhat_actual = 2 * H_sum / (w_size*(w_size-1)); % Window
    end
    if i <=1
        Issampen = bhat_actual / w_mean; % TODO Kan vara så att tot_mean egentligen ska vara mean för fönstret istället
    else 
    bhat_i = (1-alfa) * prior_b + alfa * bhat_actual;
    Issampen_moment = bhat_i / w_mean; %tot_mean is suppossed to be an exponential averaged mean
    Issampen = [Issampen Issampen_moment];
    end
end
% Exponential averaging

figure
plot(Issampen) %någonting är sus


%% TEST2 FÖR ISSAMPEN TRAININGSET 1
clear
load("afdb_1.mat")
% figure
% subplot(311)
% plot(rr) % rr interval
% subplot(312)
% plot(qrs) % qrsinterval

w_size = 8 % arbitrary window size, seconds
alfa = 0.05 % learning rate

tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr)
data_size = length(qrs) 


sum_bhat = 0;
H_sum = 0;
similarity = -1;
bhat_actual = 0;
bhat_tot = 0;
Issampen_moment = 0;
Issampen = 0;
prior_b = 0;
w_mean = 0;
for i = 1:1:data_size-w_size-1 %kontrollera w_size-1 ifall rätt iom summa N-2
    H = 0; % Heavyside step function
    for j =i:1:w_size
        %detection step of the sliding window
        % window(i), where window is a function based on w_size of the
        % rr-interval
        
        window = rr(i:i+w_size-1)
        w_mean = mean(window);
        w_std = std(window);
        r = w_std*0.4; % placeholder for now, to be replaced with adaptive deviation

        if i<2
            % nothing happens
        else
            similarity = abs(old_window-window); % TODO borde vara max-norm men osäker på vad det är + implementeringen
        end

        old_window = window; % saves the window
        if r - similarity >=0
            H = H + 1;
        end

        if i <=1
        %inget händer
        else 
            b_prior = bhat_actual; % saves prior b, if we are at large enough iteration step
        end
        H_sum = H_sum + H;
        bhat_actual = 2 * H_sum / (w_size*(w_size-1)); % Window
    end
    if i <=1
        Issampen = bhat_actual / w_mean; % TODO Kan vara så att tot_mean egentligen ska vara mean för fönstret istället
    else 
    bhat_i = (1-alfa) * prior_b + alfa * bhat_actual;
    Issampen_moment = bhat_i / w_mean; %tot_mean is suppossed to be an exponential averaged mean
    Issampen = [Issampen Issampen_moment];
    end
end
% Exponential averaging

%% Training set 2
clear
load('afdb_2.mat')

figure
ax1 = subplot(211)
plot(rr) % rr interval
title('RR-interval, Training set 2')
ylabel('Time difference')
xlabel('Sample meassure')

% plotta och visa när AF inträffar
ax2 = subplot(212)
plot(targetsRR,'Color',[0.5 0 0.8], 'LineWidth', 2)
title('AF classification')
xlabel('Sample meassure')

linkaxes([ax1 ax2], 'x')


w_size = 8 % arbitrary window size, beats
tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr) % mean out of total signal

%% Training set 3
clear
load('afdb_3.mat')
figure
ax1 = subplot(211)
plot(rr) % rr interval
title('RR-interval, Training set 3')
ylabel('Time difference')
xlabel('Sample meassure')

% plotta och visa när AF inträffar
ax2 = subplot(212)
plot(targetsRR,'Color',[0.5 0 0.8], 'LineWidth', 2)
title('AF classification')
xlabel('Sample meassure')

linkaxes([ax1 ax2], 'x')


w_size = 8 % arbitrary window size, beats
tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr) % mean out of total signal



%% Training set 4
clear
load('afdb_4.mat')

figure
ax1 = subplot(211)
plot(rr) % rr interval
title('RR-interval, Training set 4')
ylabel('Time difference')
xlabel('Sample meassure')

% plotta och visa när AF inträffar
ax2 = subplot(212)
plot(targetsRR,'Color',[0.5 0 0.8], 'LineWidth', 2)
title('AF classification')
xlabel('Sample meassure')

linkaxes([ax1 ax2], 'x')


w_size = 8 % arbitrary window size, beats
tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr) % mean out of total signal


%% Test set

%% Test set 1
clear
load('afdb_5.mat')

figure
ax1 = subplot(211)
plot(rr) % rr interval
title('RR-interval, Test1')
ylabel('Time difference')
xlabel('Sample meassure')

% plotta och visa när AF inträffar
ax2 = subplot(212)
plot(targetsRR,'Color',[0.5 0 0.8], 'LineWidth', 2)
title('AF classification')
xlabel('Sample meassure')

linkaxes([ax1 ax2], 'x')


w_size = 8 % arbitrary window size, beats
tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr) % mean out of total signal


%% Test set 2
clear
load('afdb_6.mat')
figure
ax1 = subplot(211)
plot(rr) % rr interval
title('RR-interval, Test2')
ylabel('Time difference')
xlabel('Sample meassure')

% plotta och visa när AF inträffar
ax2 = subplot(212)
plot(targetsRR,'Color',[0.5 0 0.8], 'LineWidth', 2)
title('AF classification')
xlabel('Sample meassure')

linkaxes([ax1 ax2], 'x')


w_size = 8 % arbitrary window size, beats
tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr) % mean out of total signal

%% Test set 3
clear
load('afdb_7.mat')

figure
ax1 = subplot(211)
plot(rr) % rr interval
title('RR-interval, Test3')
ylabel('Time difference')
xlabel('Sample meassure')

% plotta och visa när AF inträffar
ax2 = subplot(212)
plot(targetsRR,'Color',[0.5 0 0.8], 'LineWidth', 2)
title('AF classification')
xlabel('Sample meassure')

linkaxes([ax1 ax2], 'x')


w_size = 8 % arbitrary window size, beats
tot_std = std( rr ) % standard deviation
threshold = 0.2 * tot_std % arbitrary threshold value, if the deviation of the given window is larger than this, it should be an AF
tot_mean = sum(rr)/length(rr) % mean out of total signal
