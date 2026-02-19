using GLMakie

# Define functions with different overlap scenarios
x = range(-5, 5, length=1000)

# Scenario 1: Both positive - strong overlap
f1 = exp.(-(x .- 0.5).^2 / 2)
g1 = exp.(-(x .+ 0.5).^2 / 2)

# Scenario 2: Orthogonal - zero overlap (sine and cosine over symmetric interval)
f2 = sin.(x)
g2 = cos.(x)

# Compute the products
product1 = f1 .* g1
product2 = f2 .* g2

# Compute the overlap integrals
dx = x[2] - x[1]
overlap1 = sum(product1) * dx
overlap2 = sum(product2) * dx

# Create visualization
fig = Figure(size=(900, 900), fontsize=16)

# Plot 1: Functions with positive overlap
ax1 = Axis(fig[1, 1], xlabel="x", ylabel="Amplitude",
           title="Both Positive - Strong Overlap")
lines!(ax1, x, f1, label="f(x)", color=:teal, linewidth=3)
lines!(ax1, x, g1, label="g(x)", color=:coral, linewidth=3)
axislegend(ax1, position=:rt)

# Plot 2: Product with positive overlap
ax2 = Axis(fig[2, 1], xlabel="x", ylabel="Amplitude",
           title="Product - Overlap = $(round(overlap1, digits=3))")
band!(ax2, x, zeros(length(x)), product1, color=(:mediumpurple, 0.4))
lines!(ax2, x, product1, color=:mediumpurple, linewidth=3)

# Plot 3: Orthogonal functions
ax3 = Axis(fig[1, 2], xlabel="x", ylabel="Amplitude",
           title="Orthogonal - Zero Overlap")
lines!(ax3, x, f2, label="sin(x)", color=:teal, linewidth=3)
lines!(ax3, x, g2, label="cos(x)", color=:coral, linewidth=3)
axislegend(ax3, position=:rt)

# Plot 4: Product of orthogonal functions
ax4 = Axis(fig[2, 2], xlabel="x", ylabel="Amplitude",
           title="Product - Overlap = $(round(overlap2, digits=3))")
# Show positive and negative areas in different colors
positive_mask = product2 .> 0
negative_mask = product2 .< 0
band!(ax4, x[positive_mask], zeros(sum(positive_mask)), product2[positive_mask],
      color=(:green, 0.4), label="Positive area")
band!(ax4, x[negative_mask], zeros(sum(negative_mask)), product2[negative_mask],
      color=(:red, 0.4), label="Negative area")
lines!(ax4, x, product2, color=:orange, linewidth=3)
axislegend(ax4, position=:rt)

fig
##
save("images/function_overlap.png", fig)
