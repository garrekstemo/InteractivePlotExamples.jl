using GLMakie

# Choose a visually interesting polynomial with interesting curves
f(x) = -0.05(x-2)*(x-5)*(x-8) + 2

# Integration bounds
a, b = 1.5, 8.5
n_rectangles = 40  # Number of rectangles for Riemann sum

# Create the figure with dark theme
fig = Figure(size=(1600, 900), backgroundcolor=:black)
ax = Axis(fig[1, 1],
    backgroundcolor=:black,
    xticklabelsvisible=false,
    yticklabelsvisible=false,
    xlabelvisible=false,
    ylabelvisible=false,
    xticksvisible=false,
    yticksvisible=false,
    leftspinevisible=true,
    rightspinevisible=false,
    topspinevisible=false,
    bottomspinevisible=false,
    xgridvisible=false,
    ygridvisible=false)

# Generate smooth curve
x_smooth = range(0, 9, length=500)
y_smooth = f.(x_smooth)

# Calculate rectangle properties (using left endpoint rule)
dx = (b - a) / n_rectangles
x_left = [a + (i-1)*dx for i in 1:n_rectangles]
heights = f.(x_left)

# Plot rectangles with subtle blue-green gradient
gradient_colors = range(colorant"lightblue", colorant"mediumseagreen", length=n_rectangles)
for i in 1:n_rectangles
    poly!(ax,
        Point2f[(x_left[i], 0), (x_left[i] + dx, 0),
                (x_left[i] + dx, heights[i]), (x_left[i], heights[i])],
        color=(gradient_colors[i], 0.7),
        strokecolor=(gradient_colors[i], 0.9),
        strokewidth=1)
end

lines!(ax, x_smooth, y_smooth,
    color=:cyan,
    linewidth=4,
    label="f(x) = -0.05(x-2)(x-5)(x-8) + 2")

scatter!(ax, x_left, heights,
    color=:aqua,
    markersize=8,
    strokecolor=:cyan,
    strokewidth=1.5,
    label="Left endpoints")

xlims!(ax, 0, 9)
ylims!(ax, -0.2, 5)

fig
##
save("images/integration_plot.png", fig)
