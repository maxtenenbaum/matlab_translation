function [x_norm,y_norm] = xy2norm(fig,ax,x,y)
    figure(fig);
    xLimData = xlim;
    xLimMin = xLimData(1);
    xLimMax = xLimData(2);
    yLimData = ylim;
    yLimMin = yLimData(1);
    yLimMax = yLimData(2);
    axisData = ax.Position;
    xAxisMin = axisData(1);
    xAxisMax = axisData(3);
%     xAxisRange = xAxisMax - xAxisMin;
    yAxisMin = axisData(2);
    yAxisMax = axisData(4);
%     yAxisRange = yAxisMax - yAxisMin;
    
    x_norm = ((x-xLimMin) / (xLimMax-xLimMin)) * xAxisMax + xAxisMin;
    y_norm = ((y-yLimMin) / (yLimMax-yLimMin)) * yAxisMax + yAxisMin;
end