clear all; close all; clc

load("weightheight.mat");
plot(X(1,:), X(2,:), 'k.', 'MarkerSize',20)
hold on
axis equal
xlabel('weight')
ylabel('height')
set(gca, 'fontsize', 16)