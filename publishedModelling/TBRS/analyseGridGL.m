% columns in data file

% 1: decay
% 2: rate
% 3: reh duration
% 4: threshold
% 5: noisefactor
% 6-35: SP1
% 36-65 : SP2
% 66-74 : Dalign1
% 75-83 : Dalign2

for rehType = 1:2
	
	close all
	
	% GL1
	file = ['TBRS.GlobLocGrid9-' num2str(rehType) '.out'];
	dat = load(file);
	
	% GL2
	%dat = load('TBRS.GlobLocGrid10-1.out');
	%dat = load('TBRS.GlobLocGrid10-2.out');
	
	D1 = dat(:,66:74);
	D2 = dat(:,75:83);
	
	meanAcc = mean(dat(:,6:65),2);

	accMask = meanAcc > 0.3 & meanAcc < 0.9;
	
	min1 = -0.025;
	max1 = -0.125; % just pick this rectangle; could use SE or 2*SE, but seems to conservative and not conservative enought, respecigvely
	
% 	figure(9)
% 	scatter(D1(accMask,4),D1(accMask,3))
% 	xlabel('Lag -1');
% 	ylabel('Lag -2');
% 	axis equal;
	
	figure(1)
% 	subplot(1,3,3)
% 	%rectangle('Position',[max1,max1,min1-max1,min1-max1],'EdgeColor','w','FaceColor',[0.85 0.85 0.85])
% 	hold all
% 	scatter(D1(accMask,4),D1(accMask,6),'MarkerEdgeColor','k')
% 	xlabel('Acc Diff (Lag -1)');
% 	ylabel('Acc Diff (Lag +1)');
% 	line([-1 1],[0 0], 'Color',[0.5 0.5 0.5])
% 	line([0 0],[-1 1], 'Color',[0.5 0.5 0.5])
% 	box
% 	if rehType==1
% 		xlim([-.4 .1])
% 		ylim([-.4 .1])
% 	else
% 		xlim([-.2 .1])
% 		ylim([-.2 .1])
% 	end
	
	subplot(1,2,2)
	line([-10 10],[0 0], 'Color',[0.5 0.5 0.5])
	hold all
    xlim([-5 5])
    set(gca, 'FontSize', 16)
    D1(accMask,:)
    
	plot(-4:4, mean(D1(accMask,:)),'-ok');
	xlabel('Lag');
	ylabel('Accuracy Difference');
	ylim([-0.39 0.05])
	box
	
	subplot(1,2,1)
	SP1 = mean(dat(accMask,6:35));
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
	
	figure(1)
	set(gcf, 'Color', 'w');
    set(gcf, 'Position', [0 0 800 400])
    filen = ['TBRSpred-' num2str(rehType) 'heavyxaaa.pdf'];
    export_fig(filen)
    
    figure(2)
    subplot(1,2,2)
	line([-10 10],[0 0], 'Color',[0.5 0.5 0.5])
	hold all
    D2(accMask,:)
    
	plot(-4:4, mean(D2(accMask,:)),'-ok');
	xlabel('Lag');
	ylabel('Accuracy Difference');
    set(gca, 'FontSize', 16)
	ylim([-.05 0.2])
    xlim([-5 5])
	box
	
	subplot(1,2,1)
	SP2 = mean(dat(accMask,36:65));
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
    
    figure(2)
	set(gcf, 'Color', 'w');
    set(gcf, 'Position', [0 0 800 400])
    filen = ['TBRSpred-' num2str(rehType) 'lightxaaa.pdf'];
    export_fig(filen)
	
end
% LG = D1(:,4)< min1 & D1(:,4)> max1 & D1(:,6)< min1 & D1(:,6)> max1;
% 
% figure(2)
% subplot(2,2,3)
% line([-5 5],[0 0], 'Color',[0.5 0.5 0.5])
% hold all
% plot(-4:4, mean(D1(LG,:)),'-ok');
% xlabel('Lag');
% ylabel('Accuracy Difference');
% ylim([-0.3 0.05])
% 
% subplot(2,2,4)
% pch = 'o*s+^';
% SP1 = mean(dat(LG,6:35));
% SP1 = reshape(SP1,5,6);
% for ii=2:6
% 	plot(SP1(:,ii), ['-' pch(ii-1)], 'Color',1-[0.15 0.15 0.15].*ii,'LineWidth',1.2)
% 	hold all
% end
% plot(SP1(:,1), '--k','LineWidth',1.2)
% ylim([0 1])
% xlim([0.5 5.5])
% xlabel('Serial Position');
% ylabel('Proportion Correct');
% legend('1','2','3','4','5','Control');
% 
% 
% mean(D1(LG,3))
% mean(D1(LG,4))
% 
% 
% %plot(mean(D1(LG,:)),'-o');
% 
% %SP1 = mean(dat(LG,6:35));
% SP1 = mean(dat(:,6:35));
% 
% SP1 = reshape(SP1,5,6);
% figure(4)
% plot(SP1)
% ylim([0 1])
% xlim([0.5 5.5])
% xlabel('Serial Position');
% ylabel('Proportion Correct');
% legend('Control','1','2','3','4','5');
% 
% figure
% hist(mean(dat(:,6:35),2))
% 
% figure
% scatter(D1(LG,4),D1(LG,3))
% xlabel('Lag -1');
% ylabel('Lag +1');
% axis equal;
% 
% figure(1)
% set(gcf, 'Position', [25 25 1200 400]);
% exportfig(gcf, 'temp.eps', 'Color', 'gray', 'FontMode', 'Fixed', 'FontSize', 16, 'LineMode', 'scaled', 'LineWidth', 2, 'BoundsCode','mcode')