using GLMakie

# Define Gaussian/Lorentzian-like peaks for spectroscopy
# Peak function: A * exp(-((x - mu)^2) / (2*sigma^2))
# Area = A * sigma * sqrt(2*pi)

# For same area: A1 * sigma1 = A2 * sigma2 (approximately for visualization)

# Peak 1: Tall and narrow
mu1 = 5.0          # center position
sigma1 = 0.5       # width (narrow)
A1 = 2.0           # amplitude (tall)

# Peak 2: Short and wide
mu2 = 10.0         # center position
sigma2 = 2.0       # width (wide, 4x peak 1)
A2 = 0.5           # amplitude (short, 1/4 of peak 1)

# Generate x values
x = range(0, 15, length=1000)

# Calculate Gaussian peaks
peak1 = A1 .* exp.(-((x .- mu1).^2) ./ (2 * sigma1^2))
peak2 = A2 .* exp.(-((x .- mu2).^2) ./ (2 * sigma2^2))

# Calculate actual integrated areas using the Gaussian integral formula
area1 = A1 * sigma1 * sqrt(2*pi)
area2 = A2 * sigma2 * sqrt(2*pi)

# Create the plot
fig = Figure(size=(700, 450))
ax = Axis(fig[1, 1],
    xlabel="Wavelength / Chemical Shift (arbitrary units)",
    ylabel="Intensity (arbitrary units)",
    # title="Spectroscopic Peaks with Equal Integrated Areas"
)

# Plot both peaks with interesting colors
lines!(ax, x, peak1, linewidth=2.5, label="Peak 1: Tall & Narrow")
lines!(ax, x, peak2, linewidth=2.5, label="Peak 2: Short & Wide")

# Fill under the curves to emphasize area
band!(ax, x, zeros(length(x)), peak1, alpha=0.3)
band!(ax, x, zeros(length(x)), peak2, alpha=0.3)

fig
##
# Add equation to the plot
text!(ax, 10, 1.5,
    text=L"I(x) = A \cdot e^{-\frac{(x-\mu)^2}{2\sigma^2}}",
    fontsize=20)

# Add annotations for peak parameters
text!(ax, mu1 - 2, A1 - 0.5,
    text="h: $(A1)\nw: $(sigma1)\nA: $(round(area1, digits=3))",
    align=(:center, :bottom), fontsize=16)

text!(ax, mu2, A2 + 0.15,
    text="h: $(A2)\nw: $(sigma2)\nA: $(round(area2, digits=3))",
    align=(:center, :bottom), fontsize=16)

# axislegend(ax, position=:lt)

println("Integrated areas:")
println("Peak 1 (tall & narrow): $(round(area1, digits=4))")
println("Peak 2 (short & wide):  $(round(area2, digits=4))")
println("Ratio: $(round(area1/area2, digits=4))")

fig
##
save("images/integrated_area.png", fig)
