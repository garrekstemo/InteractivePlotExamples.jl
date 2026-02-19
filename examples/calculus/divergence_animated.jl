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
fig = Figure(size = (600, 600))
ax = Axis(fig[1, 1], aspect = DataAspect(),
    # title = "Divergence Theorem Visualization (Animated)",
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

# Plot static vector field
arrows2d!(ax, x, y, vx, vy, tiplength = 10, lengthscale = 0.3,
    tipcolor = :lightgray, shaftcolor = :lightgray)

# Create particles for animation
n_particles = 200
particle_positions = Observable(zeros(n_particles, 2))

# Initialize particles - half at source, half random
for i in 1:n_particles
    if i <= n_particles ÷ 2
        # Start particles near the source
        angle = rand() * 2π
        r = rand() * 0.2
        particle_positions[][i, 1] = source_pos[1] + r * cos(angle)
        particle_positions[][i, 2] = source_pos[2] + r * sin(angle)
    else
        # Start particles randomly in domain
        particle_positions[][i, 1] = rand() * 10 - 5
        particle_positions[][i, 2] = rand() * 10 - 5
    end
end

# Plot particles
scatter!(ax, @lift(Point2f.($particle_positions[:, 1], $particle_positions[:, 2])),
    color = :dodgerblue, markersize = 8, alpha = 0.8)

# Circle 1: Encloses the source (positive flux)
circle1_center = source_pos
circle1_radius = 1.0
θ = range(0, 2π, length=100)
circle1_x = circle1_center[1] .+ circle1_radius .* cos.(θ)
circle1_y = circle1_center[2] .+ circle1_radius .* sin.(θ)
lines!(ax, circle1_x, circle1_y, color = :steelblue, linewidth = 3,
    label = "Circle enclosing source")

# Circle 2: Encloses neither source nor sink (zero flux)
circle2_center = [0.0, 3.0]
circle2_radius = 0.8
circle2_x = circle2_center[1] .+ circle2_radius .* cos.(θ)
circle2_y = circle2_center[2] .+ circle2_radius .* sin.(θ)
lines!(ax, circle2_x, circle2_y, color = :coral, linewidth = 3,
    label = "Circle enclosing neither")

# Mark source and sink
scatter!(ax, [source_pos[1]], [source_pos[2]], marker = :circle,
    markersize = 20, color = :green, label = "Source", depth_shift = -1.0)
scatter!(ax, [sink_pos[1]], [sink_pos[2]], marker = :circle,
    markersize = 20, color = :purple, label = "Sink", depth_shift = -1.0)

# axislegend(ax, position = :lt)

# Animation loop
framerate = 30
dt = 0.05  # time step for particle updates
timestamps = range(0, 10, step=1/framerate)

record(fig, "divergence_animation.mp4", timestamps; framerate = framerate) do t
    # Update particle positions using Euler method
    for i in 1:n_particles
        px = particle_positions[][i, 1]
        py = particle_positions[][i, 2]

        # Get velocity at particle position
        vx, vy = vector_field(px, py, source_pos, sink_pos)

        # Update position
        particle_positions[][i, 1] += vx * dt
        particle_positions[][i, 2] += vy * dt

        # Reset particles that go out of bounds or reach sink
        out_of_bounds = abs(particle_positions[][i, 1]) > 5 || abs(particle_positions[][i, 2]) > 5
        dist_to_sink = sqrt((particle_positions[][i, 1] - sink_pos[1])^2 +
                           (particle_positions[][i, 2] - sink_pos[2])^2)

        if out_of_bounds || dist_to_sink < 0.3
            # Respawn at source
            angle = rand() * 2π
            r = rand() * 0.2
            particle_positions[][i, 1] = source_pos[1] + r * cos(angle)
            particle_positions[][i, 2] = source_pos[2] + r * sin(angle)
        end
    end

    notify(particle_positions)
end

fig
