using GLMakie

# Create vector field with a source and a sink
function vector_field(x, y, source_pos, sink_pos)
    # Vector from source (positive divergence)
    dx_source = x - source_pos[1]
    dy_source = y - source_pos[2]
    r_source = sqrt(dx_source^2 + dy_source^2 + 0.1)
    vx_source = dx_source / r_source^2
    vy_source = dy_source / r_source^2

    # Vector from sink (negative divergence)
    dx_sink = x - sink_pos[1]
    dy_sink = y - sink_pos[2]
    r_sink = sqrt(dx_sink^2 + dy_sink^2 + 0.1)
    vx_sink = -dx_sink / r_sink^2
    vy_sink = -dy_sink / r_sink^2

    return vx_source + vx_sink, vy_source + vy_sink
end

# Set up the plot
fig = Figure(size = (500, 500))
ax = Axis(fig[1, 1], aspect = DataAspect(),
    # title = "Divergence Theorem Visualization",
    xlabel = "x", ylabel = "y")

# Define source and sink positions
source_pos = [-2.0, 0.0]
sink_pos = [2.0, 0.0]

# Create grid for vector field
x = range(-5, 5, length=20)
y = range(-5, 5, length=20)
vx = zeros(length(x), length(y))
vy = zeros(length(x), length(y))

for i in eachindex(x)
    for j in eachindex(y)
        vx[i, j], vy[i, j] = vector_field(x[i], y[j], source_pos, sink_pos)
    end
end

# Plot vector field
arrows2d!(ax, x, y, vx, vy, tiplength = 10, lengthscale = 0.3,
    tipcolor = :gray, shaftcolor = :gray)

# Circle 1: Encloses the source (positive flux)
circle1_center = source_pos
circle1_radius = 1.0
θ = range(0, 2π, length=100)
circle1_x = circle1_center[1] .+ circle1_radius .* cos.(θ)
circle1_y = circle1_center[2] .+ circle1_radius .* sin.(θ)
lines!(ax, circle1_x, circle1_y, color = :blue, linewidth = 3,
    label = "Circle enclosing source")

# Circle 2: Encloses neither source nor sink (zero flux)
circle2_center = [0.0, 3.0]
circle2_radius = 0.8
circle2_x = circle2_center[1] .+ circle2_radius .* cos.(θ)
circle2_y = circle2_center[2] .+ circle2_radius .* sin.(θ)
lines!(ax, circle2_x, circle2_y, color = :red, linewidth = 3,
    label = "Circle enclosing neither")

# Mark source and sink
scatter!(ax, [source_pos[1]], [source_pos[2]], marker = :circle,
    markersize = 20, color = :green, label = "Source", depth_shift = -1.0)
scatter!(ax, [sink_pos[1]], [sink_pos[2]], marker = :circle,
    markersize = 20, color = :purple, label = "Sink", depth_shift = -1.0)

# axislegend(ax, position = :lt)

fig

##
save("images/divergence_plot.png", fig)