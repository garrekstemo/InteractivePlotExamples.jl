using DifferentialEquations
using GLMakie

# Reaction sequence: A -> C -> B
# Rate law: d[A]/dt = -k1[A]
#          d[C]/dt = +k1[A] - k2[C]
#          d[B]/dt = +k2[C]

function reaction!(du, u, p, t)
    A, C, B = u
    k1, k2 = p

    du[1] = -k1 * A           # dA/dt
    du[2] = +k1 * A - k2 * C  # dC/dt
    du[3] = +k2 * C           # dB/dt
end

# Parameters
k1 = 1.0          # rate constant A -> C
k2 = 0.5          # rate constant C -> B
u0 = [1.0, 0.0, 0.0]   # initial: A=1, C=0, B=0
tspan = (0.0, 10.0)

# Solve
prob = ODEProblem(reaction!, u0, tspan, (k1, k2))
sol = solve(prob, saveat=0.01)

# Plot
fig = Figure(size = (800, 600))
ax = Axis(fig[1, 1],
    xlabel = "Time",
    ylabel = "Concentration",
    title = "A → C → B")

lines!(ax, sol.t, [u[1] for u in sol.u], label = "A (reactant)", linewidth = 3)
lines!(ax, sol.t, [u[2] for u in sol.u], label = "C (intermediate)", linewidth = 3)
lines!(ax, sol.t, [u[3] for u in sol.u], label = "B (product)", linewidth = 3)

axislegend(ax, position = :rc)
fig

##
save("images/reaction_rates.png", fig)
