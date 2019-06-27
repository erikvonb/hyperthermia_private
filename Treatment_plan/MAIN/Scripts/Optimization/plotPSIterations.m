function stop = plotPSIterations(optimValues, state, filename)

stop = false;
titleString = ['Best function value: ' num2str(optimValues.bestfval)];
switch state
    case 'init'
        % plot(optimValues.iteration, optimValues.bestfval)
        plotBest = scatter(optimValues.iteration, optimValues.bestfval, 'filled');
        set(plotBest,'Tag','psoplotbestf');
        xlabel('Iteration')
        ylabel('Function value')
        title(titleString)
    case 'iter'
        plotBest = findobj(get(gca,'Children'),'Tag','psoplotbestf');
        newX = [get(plotBest,'Xdata') optimValues.iteration];
        newY = [get(plotBest,'Ydata') optimValues.bestfval];
        set(plotBest,'Xdata',newX, 'Ydata',newY);
        set(get(gca,'Title'),'String',titleString);
    case 'done'
        plotBest = findobj(get(gca,'Children'),'Tag','psoplotbestf');
        logpath = get_path('logs');
        saveas(plotBest, [logpath filesep filename '.fig'])
        saveas(plotBest, [logpath filesep filename '.png'])

end