using GLMakie

# Create rotational vector field (vortex)
function vector_field(x, y, vortex_pos, strength=1.0)
    # Vector relative to vortex center
    dx = x - vortex_pos[1]
    dy = y - vortex_pos[2]
    r = sqrt(dx^2 + dy^2 + 0.1)

    # Rotational field: perpendicular to radial direction
    # For counterclockwise rotation: (-dy, dx)
    vx = -dy * strength / r^2
    vy = dx * strength / r^2

    return vx, vy
end

# Set up the plot
fig = Figure(size = (600, 600))
ax = Axis(fig[1, 1], aspect = DataAspect(),
    xlabel = "x", ylabel = "y")

# Define vortex position
vortex_pos = [0.0, 0.0]
strength = 3.0

# Create grid for vector field
x = range(-5, 5, length=20)
y = range(-5, 5, length=20)
vx = zeros(length(x), length(y))
vy = zeros(length(x), length(y))

for i in eachindex(x)
    for j in eachindex(y)
        vx[i, j], vy[i, j] = vector_field(x[i], y[j], vortex_pos, strength)
    end
end

# Plot static vector field with smaller arrows near center
arrow_lengths = Float64[]
for i in eachindex(x)
    for j in eachindex(y)
        r = sqrt((x[i] - vortex_pos[1])^2 + (y[j] - vortex_pos[2])^2)
        # Scale down arrows near the center
        push!(arrow_lengths, min(0.3, 0.3 * r / 2.0))
    end
end

arrows2d!(ax, x, y, vx, vy, tiplength = 10,
    lengthscale = arrow_lengths,
    tipcolor = :lightgray, shaftcolor = :lightgray)

# Create particles for animation
n_particles = 200
particle_positions = Observable(zeros(n_particles, 2))

# Initialize particles at various radii around vortex
for i in 1:n_particles
    angle = rand() * 2π
    r = rand() * 4.0 + 0.5  # radius between 0.5 and 4.5
    particle_positions[][i, 1] = vortex_pos[1] + r * cos(angle)
    particle_positions[][i, 2] = vortex_pos[2] + r * sin(angle)
end

# Plot particles
scatter!(ax, @lift(Point2f.($particle_positions[:, 1], $particle_positions[:, 2])),
    color = :dodgerblue, markersize = 8, alpha = 0.8)

# Circle around vortex (non-zero circulation)
circle_center = vortex_pos
circle_radius = 2.0
θ = range(0, 2π, length=100)
circle_x = circle_center[1] .+ circle_radius .* cos.(θ)
circle_y = circle_center[2] .+ circle_radius .* sin.(θ)
lines!(ax, circle_x, circle_y, color = :coral, linewidth = 3,
    label = "Circle enclosing vortex")

# Mark vortex center
scatter!(ax, [vortex_pos[1]], [vortex_pos[2]], marker = :circle,
    markersize = 20, color = :purple, label = "Vortex center", depth_shift = -1.0)

# Animation loop
framerate = 30
dt = 0.05  # time step for particle updates
timestamps = range(0, 10, step=1/framerate)

record(fig, "curl_animation.mp4", timestamps; framerate = framerate) do t
    # Update particle positions using Euler method
    for i in 1:n_particles
        px = particle_positions[][i, 1]
        py = particle_positions[][i, 2]

        # Get velocity at particle position
        vx, vy = vector_field(px, py, vortex_pos, strength)

        # Update position
        particle_positions[][i, 1] += vx * dt
        particle_positions[][i, 2] += vy * dt

        # Reset particles that go out of bounds
        if abs(particle_positions[][i, 1]) > 5 || abs(particle_positions[][i, 2]) > 5
            # Respawn at random position around vortex
            angle = rand() * 2π
            r = rand() * 4.0 + 0.5
            particle_positions[][i, 1] = vortex_pos[1] + r * cos(angle)
            particle_positions[][i, 2] = vortex_pos[2] + r * sin(angle)
        end
    end

    notify(particle_positions)
end

fig
