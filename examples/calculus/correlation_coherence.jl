using GLMakie

# Simulate charge carrier density in a solar cell material
# Starting with a localized excitation (electron-hole pair) at position x=0
x = range(-10, 10, length=1000)

# Initial carrier density: Gaussian pulse centered at origin
carrier_density = exp.(-x.^2 / 0.5)

# Auto-correlation to measure coherence length
function autocorrelate(f, x, lag)
    dx = x[2] - x[1]
    result = 0.0
    for i in eachindex(x)
        x_shifted = x[i] - lag
        if x[1] <= x_shifted <= x[end]
            idx = searchsortedfirst(x, x_shifted)
            if idx > 1 && idx <= length(x)
                f_val = f[idx-1] + (f[idx] - f[idx-1]) * (x_shifted - x[idx-1]) / (x[idx] - x[idx-1])
                result += f[i] * f_val * dx
            end
        end
    end
    return result
end

# Compute auto-correlation for different lags
lags = range(-15, 15, length=400)
autocorr = [autocorrelate(carrier_density, x, lag) for lag in lags]

# Normalize auto-correlation
autocorr = autocorr ./ maximum(autocorr)

# Find coherence length (where correlation drops to 1/e ≈ 0.37)
coherence_threshold = 1/ℯ
coherence_idx = findfirst(autocorr[lags .>= 0] .< coherence_threshold)
coherence_length = coherence_idx !== nothing ? lags[lags .>= 0][coherence_idx] : lags[end]

# Create visualization
fig = Figure(size=(900, 650), fontsize=16)

# Plot 1: Carrier density distribution
ax1 = Axis(fig[1, 1:2], xlabel="Position (nm)", ylabel="Carrier Density",
           title="Localized Charge Carrier (Electron-Hole Pair)")
lines!(ax1, x, carrier_density, color=:teal, linewidth=3)
vlines!(ax1, [0], color=:gray, linestyle=:dash, linewidth=2, label="Excitation center")
axislegend(ax1, position=:rt)

# Plot 2: Auto-correlation showing coherence length
ax2 = Axis(fig[2, 1:2], xlabel="Lag (nm)", ylabel="Normalized Auto-correlation",
           title="Auto-correlation Reveals Coherence Length")
lines!(ax2, lags, autocorr, color=:mediumpurple, linewidth=3)
hlines!(ax2, [coherence_threshold], color=:coral, linestyle=:dash, linewidth=2,
        label="1/e threshold")
vlines!(ax2, [coherence_length, -coherence_length], color=:forestgreen,
        linestyle=:dash, linewidth=2, label="Coherence length ≈ $(round(coherence_length, digits=2)) nm")
axislegend(ax2, position=:rt)

display(fig)
