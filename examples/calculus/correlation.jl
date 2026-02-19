using GLMakie

# Define two overlapping wave packets
x = range(-10, 10, length=1000)
# Wave packet 1: centered at x=1
f = exp.(-(x .- 1).^2 / 2) .* cos.(3 * x)
# Wave packet 2: centered at x=-1
g = exp.(-(x .+ 1).^2 / 2) .* cos.(3 * x)

# Compute cross-correlation using integration
function correlate(f, g, x, lag)
    dx = x[2] - x[1]
    # Shift g by lag and compute integral of f(x) * g(x - lag)
    result = 0.0
    for i in eachindex(x)
        # Find corresponding index in g for x[i] - lag
        x_shifted = x[i] - lag
        if x[1] <= x_shifted <= x[end]
            # Linear interpolation for g at x_shifted
            idx = searchsortedfirst(x, x_shifted)
            if idx > 1 && idx <= length(x)
                g_val = g[idx-1] + (g[idx] - g[idx-1]) * (x_shifted - x[idx-1]) / (x[idx] - x[idx-1])
                result += f[i] * g_val * dx
            end
        end
    end
    return result
end

# Compute correlation for different lags
lags = range(-10, 10, length=300)
correlation = [correlate(f, g, x, lag) for lag in lags]

# Create visualization
fig = Figure(size=(900, 650), fontsize=16)

# Plot 1: Wave packets at lag = 0 (no shift)
ax1 = Axis(fig[1, 1], xlabel="x", ylabel="Amplitude",
           title="Lag = 0 (no shift)")
lines!(ax1, x, f, label="f(x)", color=:teal, linewidth=3)
lines!(ax1, x, g, label="g(x)", color=:coral, linewidth=3, linestyle=:dash)
axislegend(ax1, position=:rt)

# Plot 2: Wave packets at lag = 2 (optimal alignment)
ax2 = Axis(fig[1, 2], xlabel="x", ylabel="Amplitude",
           title="Lag = 2 (optimal alignment)")
lines!(ax2, x, f, label="f(x)", color=:teal, linewidth=3)
# Shift g by lag=2 for visualization
g_shifted = [begin
    x_shift = x[i] - 2.0
    if x[1] <= x_shift <= x[end]
        idx = searchsortedfirst(x, x_shift)
        if idx > 1 && idx <= length(x)
            g[idx-1] + (g[idx] - g[idx-1]) * (x_shift - x[idx-1]) / (x[idx] - x[idx-1])
        else
            0.0
        end
    else
        0.0
    end
end for i in eachindex(x)]
lines!(ax2, x, g_shifted, label="g(x - 2)", color=:coral, linewidth=3, linestyle=:dash)
axislegend(ax2, position=:rt)

# Plot 3: The cross-correlation function
ax3 = Axis(fig[2, 1:2], xlabel="Lag", ylabel="Cross-correlation",
           title="Cross-Correlation: Measures Overlap at Different Lags")
lines!(ax3, lags, correlation, color=:mediumpurple, linewidth=3)
scatter!(ax3, [0.0], [correlate(f, g, x, 0.0)], color=:darkorange, markersize=18, label="Lag = 0")
scatter!(ax3, [2.0], [correlate(f, g, x, 2.0)], color=:forestgreen, markersize=18, label="Lag = 2 (peak)")
axislegend(ax3, position=:rt)

fig

##
save("images/cross_correlation.png", fig)