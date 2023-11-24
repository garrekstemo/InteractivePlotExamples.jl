using GLMakie

t = -2π:0.001:2π
obs = [Observable(0.0) for s in 1:3]

y = @lift(@. sin(π * ($(obs[2]) * t + $(obs[3]))) * exp(- t^2 / (2 * $(obs[1])^2)))
gauss = @lift(@. exp(- t^2 / (2 * $(obs[1])^2)))

fig = Figure()

ax = Axis(fig[1, 1], ylabel = "y", xlabel = "x")

sg = SliderGrid(fig[2, 1],
    (label = "Width", range = 0.1:0.01:10, format = "{:.1f}", startvalue=1),
    (label = "Angular Freq.", range = 0:0.01:10, format = "{:.1f}π", startvalue=0.5),
    (label = "Phase", range = -6:0.01:6, format = "{:0.1f}π", startvalue=0),
)

sliderobservables = [s.value for s in sg.sliders]

for (i, o) in enumerate(obs)
    connect!(o, sliderobservables[i])
end

lines!(t, y)
lines!(t, gauss, linestyle = :dash)
ylims!(-1.1, 1.1)

fig