using GLMakie

function loss(model, xdata, ydata, p)
    sum(((x, y),) -> abs2(y - model(x, p)), zip(xdata, ydata))
end
function squared_surface(model, xdata, ydata, p1, p2)
    return [loss(model, xdata, ydata, [p1[i], p2[j]]) for i in eachindex(p1), j in eachindex(p2)]
end
double_exp(x, p) = @. exp(-x / p[1]) + exp(-x / p[2])

p = [11, 5]
xmax = Observable(20.0)
xpoints = Observable(100)
noise = Observable(0.02)

x = @lift(range(0, $(xmax), length = $(xpoints)))
y = @lift(double_exp($(x), p) .+ $(noise) .* randn.())
p1 = range(1, 30, length = 100)
p2 = range(1, 30, length = 100)
surf = @lift(log10.(squared_surface(double_exp, $(x), $(y), p1, p2)))

f = Figure(size = (500, 900))

ax1 = Axis(f[1, 1])
lines!(ax1, x, y, color = :black)

ax2 = Axis(f[2, 1],
    xticks = LinearTicks(7),
    yticks = LinearTicks(7),
    )
heatmap!(p1, p2, surf)

sg = SliderGrid(f[3, 1],
    (label = "x_max", range = 0.5:100, format = "{:.1f}", startvalue = 20),
    (label = "num points", range = 2:1000, startvalue = 100),
    (label = "noise", range = 0.0:0.005:0.1, startvalue = 0.02),
)

sliderobservables = [s.value for s in sg.sliders]

connect!(xmax, sliderobservables[1])
connect!(xpoints, sliderobservables[2])
connect!(noise, sliderobservables[3])

on(xmax) do _
    autolimits!(ax1)
    autolimits!(ax2)
end

f