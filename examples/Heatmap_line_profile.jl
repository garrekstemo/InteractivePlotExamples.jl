using GLMakie

function gaussian(p, x, y)
    a, x0, y0, σx, σy = p
    return a * exp(-((x - x0)^2 / (2 * σx^2 ) + (y - y0)^2 / (2 * σy^2 )))
end

# Generate 2D Gaussian function
x = range(-100, 100, step=0.5)
y = range(-100, 100, step=0.5)
p = [1, 0, 0, 20, 30]
z = zeros(Float64, length(x), length(y))

for (i, j) in enumerate(x)
    for (m, n) in enumerate(y)
        z[i, m] = gaussian(p, j, n)
    end
end

# Create figure
fig = Figure(size = (450, 900))
DataInspector()

# Define observables
x_line = Observable(100.0)
y_line = Observable(50.0)
xdata = Observable(z[:, div(length(y), 2)])
ydata = Observable(z[div(length(x), 2), :])

# Plot heatmap and cursor lines
ax1 = Axis(fig[1,1], title = "2D Gaussian function", xlabel = "x", ylabel = "y")
heatmap!(x, y, z)
vlines!(x_line, color = :red)
hlines!(y_line, color = :red)

# Plot cuts of the 2D data
ax2 = Axis(fig[2, 1], title = "Cut along x-axis", xlabel = "x", ylabel = "z")
ax3 = Axis(fig[3, 1], title = "Cut along y-axis", xlabel = "y", ylabel = "z")

lines!(ax2, x, xdata)
lines!(ax3, y, ydata)


# on-do Block(executed when triggered)
on(events(ax1).mouseposition) do mpos
    xpos = mouseposition(ax1.scene)[1]
    ypos = mouseposition(ax1.scene)[2]

    x_line[] =  trunc(Int,mouseposition(ax1.scene)[1])
    y_line[] =  trunc(Int,mouseposition(ax1.scene)[2])
    xdata[] = z[:, findfirst(isapprox(ypos, atol = 0.5), y)]
    ydata[] = z[findfirst(isapprox(xpos, atol = 0.5), x), :]
end

fig