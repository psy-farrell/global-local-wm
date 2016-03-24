% columns in data file

% 1-5: parameters
% 6-35: SP1
% 36-65 : SP2
% 66-74 : Dalign1
% 75-83 : Dalign2

close all; clear all

% GL1
dat = load('SOB.GlobLocGrid10.out');
% GL2
%dat = load('SOB.GlobLocGrid11.out');

D1 = dat(:,66:74);
D2 = dat(:,75:83);

meanAcc = mean(dat(:,6:65),2);

mask = meanAcc > 0.3 & meanAcc < 0.9; %& filter out v accurate and v poor performance
SPdiff1 = [(dat(:,6+5)-dat(:,1+5)) ...
    (dat(:,12+5)-dat(:,2+5)) ...
    (dat(:,18+5)-dat(:,3+5)) ...
    (dat(:,24+5)-dat(:,4+5)) ...
    (dat(:,30+5)-dat(:,5+5))];
SPdiff2 = [(dat(:,6+35)-dat(:,1+35)) ...
    (dat(:,12+35)-dat(:,2+35)) ...
    (dat(:,18+35)-dat(:,3+35)) ...
    (dat(:,24+35)-dat(:,4+35)) ...
    (dat(:,30+35)-dat(:,5+35))];
%SPmaxm = max(SPdiff,[],2) - min(SPdiff,[],2);
SPmaxm1 = mean(SPdiff1(:,1:2),2)-mean(SPdiff1(:,4:5),2);
SPmaxm2 = mean(SPdiff2(:,1:2),2)-mean(SPdiff2(:,4:5),2);

min1 = -0.025;
max1 = -0.125; % just pick this rectangle; could use SE or 2*SE, but seems to conservative and not conservative enought, respecigvely

figure(9)
scatter(D1(mask,3),D1(mask,5))
xlabel('Lag -1');
ylabel('Lag -2');
axis equal;


datdiff = [0.7750-0.9000 0.6500-0.7562 ...
    0.5750-0.7250 0.5250-0.6625 0.5938-0.7063];

SPmaxd = mean(datdiff(1:2)-datdiff(4:5));
figure(22)
scatter(SPmaxm1(mask,:), D1(mask,5));
hold all
scatter(SPmaxd, -0.1262);
line(SPmaxd+[-.1161 .1161],[-0.1262 -0.1262]);
line([SPmaxd SPmaxd],-0.1262+[-0.0469 0.0469]);

asym1 = sum(D1(:,1:4),2)-sum(D1(:,6:9),2);
asym2 = sum(D2(:,1:4),2)-sum(D2(:,6:9),2);

figure(24)
subplot(1,2,1)
hold all
line(.0094+[-0.0924 0.0924],[-0.0729 -0.0729], 'LineWidth', 4);
line([.0094 0.0094],-0.0729+[-0.2774  0.2774], 'LineWidth', 4);
scatter(SPmaxm1(mask,:),asym1(mask), 20, [0.5 0.5 0.5])
scatter(.0094, -0.0729);

xlabel('SPC difference')
ylabel('Asymmetry');
% xlim([-0.2 1]);
% ylim([-1 0.4]);
set(gca, 'FontSize', 16)
title('High Density Exception');
xlim([-0.25 0.5]);
ylim([-1 0.25]);

subplot(1,2,2)
k2 = sum(D2(:,1:4),2)-sum(D2(:,6:9),2);
hold all
line(0.0406+[-0.1056 0.1056],[-0.0396 -0.0396], 'LineWidth', 4);
line([0.0406 0.0406],-0.0396+[-0.2780  0.2780], 'LineWidth', 4);
scatter(SPmaxm2(mask,:),asym2(mask), 20, [0.5 0.5 0.5])
scatter(0.0406, -0.0396);

xlabel('SPC difference')
ylabel('Asymmetry');
xlim([-0.8 0.2]);
ylim([-0.4 0.4]);
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 16)
set(gcf, 'Position', [0 0 800 400])
title('Low Density Exception');
export_fig 'SOBspaceE1aaa.pdf' -nocrop

%%

figure(1)
subplot(1,3,3)
line([-10 10],[0 0], 'Color',[0.5 0.5 0.5])
hold all
set(gca, 'FontSize', 16)
xlim([-5 5]);
D1(mask,:)

plot(-4:4, mean(D1(mask,:)),'-^k');
xlabel('Lag');
ylabel('Accuracy Difference');
box

subplot(1,3,1)
SP1 = mean(dat(mask,6:35));
SP1 = reshape(SP1,5,6);
for ii=2:6
    %plot(SP1(:,ii), '-o', 'Color',1-[0.15 0.15 0.15].*ii,'LineWidth',1.2,'MarkerEdgeColor','w')
    plot(SP1(:,ii), '-o', 'Color',[0.5 0.5 0.5],'LineWidth',1.2,'MarkerEdgeColor','w')
    text((1:5)-.05,SP1(:,ii),num2str(ii-1),'FontSize',14)
    hold all
end
plot(SP1(:,1), '--k','LineWidth',1.2)
ylim([0 1])
xlim([0.5 5.5])
xlabel('Serial Position');
ylabel('Proportion Correct');
set(gca, 'FontSize', 16)
%legend('1','2','3','4','5','Control','Location','SouthWest');

subplot(1,3,3)
line([-10 10],[0 0], 'Color',[0.5 0.5 0.5])
hold all
xlim([-5 5])
D2(mask,:)

plot(-4:4, mean(D2(mask,:)),'-^k','MarkerFaceColor','k');
xlabel('Lag');
ylabel('Accuracy Difference');
set(gca, 'FontSize', 16)
ylim([-0.5 0.3])
box

subplot(1,3,2)
SP2 = mean(dat(mask,36:65));
SP2 = reshape(SP2,5,6);
for ii=2:6
    %plot(SP1(:,ii), '-o', 'Color',1-[0.15 0.15 0.15].*ii,'LineWidth',1.2,'MarkerEdgeColor','w')
    plot(SP2(:,ii), '-o', 'Color',[0.5 0.5 0.5],'LineWidth',1.2,'MarkerEdgeColor','w')
    text((1:5)-.05,SP2(:,ii),num2str(ii-1),'FontSize',14)
    hold all
end
plot(SP2(:,1), '--k','LineWidth',1.2)
ylim([0 1])
xlim([0.5 5.5])
xlabel('Serial Position');
ylabel('Proportion Correct');
set(gca, 'FontSize', 16)

set(gcf, 'Color', 'w');
set(gcf, 'Position', [0 0 900 300])
export_fig 'SOBpred.pdf' -nocrop

%%

%closest match
dataSPC = [     0.7750    0.8063    0.8250    0.8438    0.8375    0.9000
    0.7250    0.6500    0.7188    0.7250    0.7625    0.7562
    0.6750    0.6125    0.5750    0.6188    0.6750    0.7250
    0.6562    0.6000    0.5500    0.5250    0.6000    0.6625
    0.7063    0.6375    0.6937    0.7125    0.5938    0.7063];
% control condition is last in data, first in model
datadiffs = [dataSPC(:,6) dataSPC(:,1:5) - repmat(dataSPC(:,6),1,5)];
datadiffs = repmat(datadiffs(:)',size(dat,1),1);
moddiffs = [dat(:,6:10) dat(:,11:35)-repmat(dat(:,6:10),1,5)];
devs = sqrt(mean((moddiffs-datadiffs).^2,2));
[i,j] = min(devs)

SP1 = reshape(dat(j,6:35),5,6);
figure(4)
plot(SP1)
ylim([0 1])
xlim([0.5 5.5])
xlabel('Serial Position');
ylabel('Proportion Correct');
legend('Control','1','2','3','4','5');
