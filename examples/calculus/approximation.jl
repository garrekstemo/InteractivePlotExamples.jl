using GLMakie

# Pendulum: restoring force
# Exact: F = -mg*sin(θ)
# Small angle approximation: F ≈ -mg*θ

g = 9.8
m = 1.0

function exact_force(θ)
    return -m * g * sin(θ)
end

# Linear approximation at θ0 = 0
θ0 = 0.0
F0 = exact_force(θ0)

# Derivative at θ0
# d/dθ[-mg*sin(θ)] = -mg*cos(θ)
slope = -m * g * cos(θ0)

# Linear approximation: F ≈ F0 + slope*(θ - θ0) = -mg*θ
function linear_approx(θ)
    return F0 + slope * (θ - θ0)
end

# Plot
θ = -1.0:0.01:1.0

fig = Figure(size = (500, 400))
ax = Axis(fig[1, 1],
    xlabel = "Angle θ (radians)",
    ylabel = "Restoring force F (N)",
    title = "Pendulum: Small Angle Approximation")

lines!(ax, θ, exact_force.(θ), label = "Exact: F = −mg·sin(θ)", linewidth = 3)
lines!(ax, θ, linear_approx.(θ), label = "Approximation: F ≈ −mg·θ", linewidth = 3, linestyle = :dash)
scatter!(ax, [θ0], [F0], markersize = 15, color = :red, label = "Linearization point")

# Equation
text!(ax, 0.5, -4.0, text = "sin(θ) ≈ θ", fontsize = 20)

# Small angle region annotation
vspan!(ax, -0.2, 0.2, color = (:green, 0.1))
text!(ax, 0.1, 0, text = "Good approximation\n(small angles)", fontsize = 20)

axislegend(ax, position = :lb)
fig

##
save("images/small_angle_approximation.png", fig)