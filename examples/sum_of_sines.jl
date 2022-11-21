using GLMakie
using SomeMakieThemes
set_theme!(theme_retina())

x = 0:0.01:4π
obs = [Observable(0.0) for s in 1:6]

sine(x, a, ω, ϕ) = @. a * sin(0.5 * ω * π * x + ϕ * 0.5 * π)

y1 = @lift(sine(x, $(obs[1]), $(obs[2]), $(obs[3])))
y2 = @lift(sine(x, $(obs[4]), $(obs[5]), $(obs[6])))
y3 = @lift($(y1) + $(y2))

fig = Figure()
display(fig)

sg = SliderGrid(fig[1:2, 2],
    (label = L"a_1", range = 0.1:0.01:3, format = "{:.1f}", startvalue = 1),
    (label = L"ω_1", range = 0:0.01:10, format = "{:.1f}π/2", startvalue = 1),
    (label = L"δ_1", range = -6:0.01:6, format = "{:0.1f}π/2", startvalue = 0),
    (label = L"a_2", range = 0.1:0.01:3, format = "{:.1f}", startvalue = 1),
    (label = L"ω_2", range = 0:0.01:10, format = "{:.1f}π/2", startvalue = 1),
    (label = L"δ_2", range = -6:0.01:6, format = "{:0.1f}π/2", startvalue = 1),
    tellheight = false,
)

sliderobservables = [s.value for s in sg.sliders]

for (i, o) in enumerate(obs)
    connect!(o, sliderobservables[i])
end

xtickvals = range(0, 4π, length = 9)
xtickformat = ["0", "π/2", "π", "3π/2", "2π", "5π/2", "3π", "7π/2", "4π"]

ax1 = Axis(fig[1, 1], title = "Independent sine waves", xlabel = "t", ylabel = "y",
            xticks = (xtickvals, xtickformat))

lines!(x, y1, label = L"f_1")
lines!(x, y2, label = L"f_2")
ylims!(-3.2, 3.2)
axislegend(ax1)

ax2 = Axis(fig[2, 1], title = "Sum of sine waves", xlabel = "t", ylabel = L"f_1 + f_2",
            xticks = (xtickvals, xtickformat))
lines!(x, y3)
ylims!(-6.4, 6.4)
