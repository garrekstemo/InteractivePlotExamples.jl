using GLMakie

himmelblau(x, y) = (x^2 + y - 11)^2 + (x + y^2 - 7)^2  # Himmelblau's function
x_poly = range(-6, 6, length = 200)
y_poly = range(-6, 6, length = 200)
surf_poly = [himmelblau(x, y) for x in x_poly, y in y_poly]

rosenbrock(x, y) = (1 - x)^2 + 100 * (y - x^2)^2  # Rosenbrock's function
x_ros = range(-2, 2, length = 200)
y_ros = range(-1, 3, length = 200)
surf_ros = [rosenbrock(x, y) for x in x_ros, y in y_ros]


f = Figure(size = (900, 900))
DataInspector()

ax = Axis(f[1, 1],
    title = "Himmelblau's Function\nf(x, y) = (x² + y - 11)² + (x + y² - 7)²\nLog scale",
    xlabel = "x",
    ylabel = "y",
)
contourf!(x_poly, y_poly, log10.(surf_poly), levels = 50, colormap = :tempo)
# contour!(x_poly, y_poly, surf_poly, levels = 70)
Colorbar(f[1, 2], label = "f(x, y)", colormap = :deep)

ax2 = Axis3(f[2, 1],
    xlabel = "x",
    ylabel = "y",
    zlabel = "f(x, y)",
)
surface!(x_poly, y_poly, surf_poly, colormap = :Egypt)

ax3 = Axis(f[1, 3],
    title = "Rosenbrock's Function\nf(x, y) = (1 - x)² + 100(y - x²)²\nLog scale",
    xlabel = "x",
    ylabel = "y",
)
contourf!(x_ros, y_ros, log10.(surf_ros), levels = 50, colormap = :tempo)
# contour!(x_ros, y_ros, surf_ros, levels = 70)
Colorbar(f[1, 4], label = "f(x, y)", colormap = :deep)

colsize!(f.layout, 1, Aspect(1, 1.0))
colsize!(f.layout, 3, Aspect(1, 1.0))
resize_to_layout!(f)

f

##
save("images/loss_surface.png", f)