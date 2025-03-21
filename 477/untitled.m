X = [linspace(0,100,100); linspace(0,100,100); linspace(0,100,100)]
Y = [randi(100,1,100); randi(100,1,100); randi(100,1,100)]

colors = ['r' 'g' 'b']
fig = figure;
hold on
for i=1:3
  disp(colors(i));
  scatter(X(i, :), Y(i, :),colors(i));
end;
hold off

resp = fig2plotly(fig, 'strip',false)
plotly_url = resp.url;