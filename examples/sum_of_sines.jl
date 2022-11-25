using GLMakie
using SomeMakieThemes
set_theme!(theme_retina())

x = 0:0.01:8π
obs = [Observable(0.0) for s in 1:6]
sine(x, a, ω, ϕ) = @. a * sin((ω * x + ϕ) * π)

y1 = @lift(sine(x, $(obs[1]), $(obs[2]), $(obs[3])))
y2 = @lift(sine(x, $(obs[4]), $(obs[5]), $(obs[6])))
y3 = @lift($(y1) + $(y2))

fig = Figure()
display(fig)

color1 = :steelblue3
color1a = :midnightblue
color2 = :orange
color2a = :firebrick4

sg = SliderGrid(fig[1:2, 2][1, 1],
    (label = L"a_1", range = 0.1:0.01:3, format = "{:.1f}", startvalue = 1, 
        color_active_dimmed = color1, color_active = color1a),
    (label = L"ω_1", range = 0:0.01:10, format = "{:.1f}π", startvalue = 1,
        color_active_dimmed = color1, color_active = color1a),
    (label = L"δ_1", range = -6:0.01:6, format = "{:0.1f}π", startvalue = 0,
        color_active_dimmed = color1, color_active = color1a),
    (label = L"a_2", range = 0.1:0.01:3, format = "{:.1f}", startvalue = 1,
        color_active_dimmed = color2, color_active = color2a),
    (label = L"ω_2", range = 0:0.01:10, format = "{:.1f}π", startvalue = 1,
        color_active_dimmed = color2, color_active = color2a),
    (label = L"δ_2", range = -6:0.01:6, format = "{:0.1f}π", startvalue = 0.5,
        color_active_dimmed = color2, color_active = color2a),
    tellheight = false,
)


sliderobservables = [s.value for s in sg.sliders]

for (i, o) in enumerate(obs)
    connect!(o, sliderobservables[i])
end

label = lift(sliderobservables[2], sliderobservables[5]) do s1, s2
    return "ω_2 / ω_1 = $(round(s2 / s1, digits=2))"
end

lb = Label(fig[1:2, 2][2, 1], label, tellwidth = false)

# xtickvals = range(0, 4π, length = 9)
# xtickformat = ["0", "π/2", "π", "3π/2", "2π", "5π/2", "3π", "7π/2", "4π"]

ax1 = Axis(fig[1, 1], title = "Independent sine waves", xlabel = "t", ylabel = "y",
            # xticks = (xtickvals, xtickformat))
)

lines!(x, y1, label = L"f_1", color = color1)
lines!(x, y2, label = L"f_2", color = color2)
ylims!(-3.1, 3.1)
axislegend(ax1)

ax2 = Axis(fig[2, 1], title = "Sum of sines", xlabel = "t", ylabel = L"f_1 + f_2",
            # xticks = (xtickvals, xtickformat))
)
lines!(x, y3, color = :indigo)
ylims!(-5.2, 5.2)
