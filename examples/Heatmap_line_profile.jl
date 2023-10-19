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

hline = Observable(1.0)
vline = Observable(1.0)
xdata = Observable(z[:, div(length(y), 2)])
ydata = Observable(z[div(length(x), 2), :])


fig = Figure(resolution = (500, 900))

ax1 = Axis(fig[1, 1], title = "2D Gaussian function", xlabel  = "x", ylabel = "y")
heatmap!(x, y, z)
vlines!(hline, color = :red)
hlines!(vline, color = :red)

ax2 = Axis(fig[2,1], title = "Horizontal cut", xlabel  = "x", ylabel = "Intensity (arb.)")
ax3 = Axis(fig[3,1], title = "Vertical cut", xlabel  = "y", ylabel = "Intensity (arb.)")
lines!(ax2, x, xdata)
lines!(ax3, y, ydata)


# on-do Block(executed when triggered)
on(events(ax1).mouseposition) do mpos
    xpos = mouseposition(ax1.scene)[1]
    ypos = mouseposition(ax1.scene)[2]

    hline[] =  trunc(Int,mouseposition(ax1.scene)[1])
    vline[] =  trunc(Int,mouseposition(ax1.scene)[2])
    xdata[] = z[:, findfirst(isapprox(ypos, atol = 0.5), y)]
    ydata[] = z[findfirst(isapprox(xpos, atol = 0.5), x), :]
end

fig