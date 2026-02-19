using GLMakie

x = range(-10, 10, length=1000)
y = 1.0 ./ (1 .+ exp.(-x))

dy_dx(x_val) = (1.0 / (1 + exp(-x_val))) * (1 - 1.0 / (1 + exp(-x_val)))


fig = Figure(size=(1200, 700), fontsize=24)
ax = Axis(fig[1, 1],
          xlabel="Input Parameter (x)",
          ylabel="Output f(x)",
          title="Sensitivity Analysis: High vs Low Sensitivity Regions",
          xlabelsize=28,
          ylabelsize=28,
          titlesize=32
)

lines!(ax, x, y, linewidth=3, color=:navy)

# HIGH SENSITIVITY region (x=0, middle of sigmoid - steepest part)
x1 = 0.0
y1 = 1.0 / (1 + exp(-x1))
slope1 = dy_dx(x1)
x_tan1 = range(x1-2.0, x1+2.0, length=100)
y_tan1 = y1 .+ slope1 .* (x_tan1 .- x1)

lines!(ax, x_tan1, y_tan1, linestyle=:dash, linewidth=3, color=:red)
scatter!(ax, [x1], [y1], markersize=20, color=:red)
text!(ax, x1, y1-0.2,
      text="High sensitivity\ndσ/dx = $(round(slope1, digits=2))\nSmall input change → Large output change",
      align=(:left, :center), fontsize=20, color=:black)

# LOW SENSITIVITY region 1 (x=-5, lower plateau)
x2 = -5.0
y2 = 1.0 / (1 + exp(-x2))
slope2 = dy_dx(x2)
x_tan2 = range(x2-2.0, x2+2.0, length=100)
y_tan2 = y2 .+ slope2 .* (x_tan2 .- x2)

lines!(ax, x_tan2, y_tan2, linestyle=:dash, linewidth=3, color=:green)
scatter!(ax, [x2], [y2], markersize=20, color=:green)
text!(ax, x2 - 4, y2 + 0.15,
      text="Low sensitivity\ndσ/dx ≈ $(round(slope2, digits=3))",
      align=(:left, :center), fontsize=20, color=:black)

# LOW SENSITIVITY region 2 (x=5, upper plateau)
x3 = 5.0
y3 = 1.0 / (1 + exp(-x3))
slope3 = dy_dx(x3)
x_tan3 = range(x3-2.0, x3+2.0, length=100)
y_tan3 = y3 .+ slope3 .* (x_tan3 .- x3)

lines!(ax, x_tan3, y_tan3, linestyle=:dash, linewidth=3, color=:green)
scatter!(ax, [x3], [y3], markersize=20, color=:green)
text!(ax, x3 + 3, y3 - 0.15,
      text="Low sensitivity\ndσ/dx ≈ $(round(slope3, digits=3))",
      align=(:right, :center), fontsize=20, color=:black)

band!(ax, [-2, 2], [0, 0], [1, 1], color=(:red, 0.1))
band!(ax, [-10, -4], [0, 0], [1, 1], color=(:green, 0.1))
band!(ax, [4, 10], [0, 0], [1, 1], color=(:green, 0.1))

text!(ax, -8, 0.95, text="Sigmoid Function", fontsize=24, color=:navy, font=:bold)
text!(ax, -8, 0.85, text="σ(x) = 1/(1+e⁻ˣ)", fontsize=28, color=:navy, font=:bold)


fig
##
save("images/sensitivity_visualization.png", fig)