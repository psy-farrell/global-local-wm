% columns in data file

% 1-5: parameters
% 6-30: SP1
% 31-38 : Dalign1

close all; clear all

% GL3
dat = load('SOB.GlobLocGrid12.out');

D1 = dat(:,31:38);

meanAcc = mean(dat(:,6:30),2);

mask = meanAcc > 0.3 & meanAcc < 0.9;
accMask = mask;

SPdiff = [mean(dat(:,(6:7)+5)-dat(:,(1:2)+5),2) ...
    mean(dat(:,(12:13)+5)-dat(:,(2:3)+5),2) ...
    mean(dat(:,(18:19)+5)-dat(:,(3:4)+5),2) ...
    mean(dat(:,(24:25)+5)-dat(:,(4:5)+5),2)];
SPmaxm = SPdiff(:,1)-SPdiff(:,4);

figure(23)
k1 = mean(D1(:,4:5),2)-mean([D1(:,3) D1(:,6)],2);
k2 = sum(D1(:,1:3),2)-sum(D1(:,6:8),2);
scatter(k1(mask),k2(mask))
hold all
scatter(-0.0575,-0.0729)
xlabel('Locality');
ylabel('Asymmetry');

% ans =
%     0.0094
% ans =
%     0.0924
figure(24)
hold all
line(-0.1364+[-0.0741 0.0741],[-0.0803 -0.0803], 'LineWidth', 4);
line([-0.1364 -0.1364],-0.0803+[-0.1820  0.1820], 'LineWidth', 4);
scatter(SPmaxm(mask,:),k2(mask), 20, [0.5 0.5 0.5])
scatter(-0.1364, -0.0803);

xlabel('SPC difference')
ylabel('Asymmetry');
xlim([-1 0.2]);
ylim([-0.3 0.5]);
set(gcf, 'Color', 'w');
set(gca, 'FontSize', 16)
set(gcf, 'Position', [0 0 400 400])
export_fig 'SOBspaceE2.pdf' -nocrop


figure(1)
subplot(1,2,2)
line([-100 100],[0 0], 'Color',[0.5 0.5 0.5])
hold all
xlim([0.5 8.5])
set(gca, 'FontSize', 16)
D1(accMask,:)

plot(1:8, mean(D1(accMask,:)),'-ok');
xlabel('Lag');
ylabel('Accuracy Difference');
set(gca,'XTick',1:8)
set(gca,'XTickLabel',{'-3','-2','-1','0(1)','0(2)','1','2','3'})
ylim([-0.1 0.3])
box

subplot(1,2,1)
SP1 = mean(dat(accMask,6:30));
SP1 = reshape(SP1,5,5);
for ii=2:5
    %plot(SP1(:,ii), '-o', 'Color',1-[0.15 0.15 0.15].*ii,'LineWidth',1.2,'MarkerEdgeColor','w')
    plot(SP1(:,ii), '-o', 'Color',[0.5 0.5 0.5],'LineWidth',1.2,'MarkerEdgeColor','w')
    text((1:5)-.05,SP1(:,ii),[num2str(ii-1) num2str(ii)] ,'FontSize',14)
    hold all
end
plot(SP1(:,1), '--k','LineWidth',1.2)
ylim([0 1])
xlim([0.5 5.5])
xlabel('Serial Position');
ylabel('Proportion Correct');
set(gca, 'FontSize', 16)
%legend('1','2','3','4','5','Control','Location','SouthWest');

figure(1)
set(gcf, 'Color', 'w');
set(gcf, 'Position', [0 0 800 400])
filen = ['SOBpredE2.pdf'];
export_fig(filen)