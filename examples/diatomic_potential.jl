# Based on
# J. P. Dahl and M. Springborg, The Morse Oscillator in Position Space, Momentum Space, and Phase Space, The Journal of Chemical Physics 88, 4535 (1988).
# and
# https://scipython.com/blog/the-morse-oscillator/

using GLMakie

const u = 1.6605390666e-27  # atomic mass constant
const c_0 = 3e8
const h = 6.62607015e-34
const ħ = h / 2π
const joules = 100 * h * c_0

"""
    morse(q, λ)

λ and q parameterize several molecular parameters.

λ = √(2 * m * D / (α * ħ))

q = (m * ω_0 / ħ)^(1/2) * x = α * √λ * x
"""
function morse_potential(q, q_e, D, a)
    @. D * (1 - exp(-a * (q - q_e)))^2
end

function harmonic_potential(q, q_e, D, a)
    @. D * a^2 * (q - q_e)^2
end

function morse_energies(n, ω_0, ω0χ0)
    @. ω_0 * (n + 0.5) - ω0χ0 * (n + 0.5)^2
end

function endpoints_morse(energy, q_eq, D, a)
    b = @. sqrt(energy / D)
    left = @. q_eq - log(1 + b) / a
    right = @. q_eq - log(1 - b) / a
    return left, right
end

function endpoints_harmonic(energies, q_eq, D, a)
    left = @. q_eq - sqrt(energies / D) / a
    right = @. q_eq + sqrt(energies / D) / a
    return left, right
end

ω_0 = Observable(1000.0)
ω0χ = Observable(50.0)

mass_A = 1
mass_B = mass_A
μ = mass_A * mass_B / (mass_A + mass_B) * u
D = @lift($(ω_0)^2 / (4 * $ω0χ) * joules)
a = @lift($ω_0 * π * c_0 * 100 * sqrt(2 * μ / $D))
λ = @lift(sqrt(2 * μ * $D) / ($a * ħ))

n_max = @lift(Int(floor($λ - 0.5)))

ns =@lift(0:$n_max)
q_e = 1.27455e-10
q_min = q_e - log(10) / to_value(a)
q_max = q_e - log(1 - 0.9999) / to_value(a)
q = range(q_min, q_max, length = 1000)


morse = @lift(morse_potential(q, q_e, $D, $a))
harmonic = @lift(harmonic_potential(q, q_e, $D, $a))
energies = @lift(morse_energies($ns, $ω_0, $ω0χ))
harmonic_energies = @lift(@. $ω_0 * ($ns + 0.5))


fig = Figure(size = (900, 500))
DataInspector()

l1 = Label(fig, L"V_m(q) = D (1 - e^{-a  (q - q_e)})^2")
l2 = Label(fig, L"E_m = ω_0\left(n + \frac{1}{2}\right) - ω_0χ_0\left(n + \frac{1}{2}\right)^2")
l3 = Label(fig, L"ω_0 = \frac{a}{2πc}\sqrt{\frac{2D}{m}}, \quad ω_0χ_0 = \frac{ω_0^2}{4D}")

toggle_m = Toggle(fig, active = true)
toggle_h = Toggle(fig, active = true)
label_m = Label(fig, "Morse")
label_h = Label(fig, "Harmonic")
    
sg = SliderGrid(fig,
        (label = L"ω_0", range = 100:0.1:8000, format="{:.1f} cm⁻¹", startvalue=1000),
        (label = L"ω_0χ", range = 1:0.1:200, format="{:.1f} cm⁻¹", startvalue=50),
        tellheight = false,
        width = 300,
)

fig[1, 2][1, 1] = vgrid!(
    l1,
    l2,
    l3,
    tellheight = false
)
fig[1, 2][2, 1] = grid!(hcat([toggle_m, toggle_h], [label_m, label_h]), tellheight = false)
fig[1, 2][3, 1] = vgrid!(
        sg,
        tellheight=false
)

sliderobservables = [s.value for s in sg.sliders]
connect!(ω_0, sliderobservables[1])
connect!(ω0χ, sliderobservables[2])

ax = Axis(fig[1, 1], title = "Diatomic potential model", xlabel = "Intermolecular distance (Å)", ylabel = "Wavenumbers (cm⁻¹)",)
line_m = lines!(q .* 1e10, @lift($morse ./ joules), label = "Morse", color = :firebrick4)
line_h = lines!(q .* 1e10, @lift($harmonic ./ joules), label = "Harmonic", color = :steelblue3)


lows_m = @lift(endpoints_morse($energies .* joules, q_e, $D, $a)[1] .* 1e10)
highs_m = @lift(endpoints_morse($energies .* joules, q_e, $D, $a)[2] .* 1e10)
vals_m = @lift(morse_energies($ns, $ω_0, $ω0χ))
lows_h = @lift(endpoints_harmonic($harmonic_energies .* joules, q_e, $D, $a)[1] .* 1e10)
highs_h = @lift(endpoints_harmonic($harmonic_energies .* joules, q_e, $D, $a)[2] .* 1e10)
vals_h = @lift($ω_0 * ($ns .+ 0.5))

hline_m = rangebars!(vals_m, lows_m, highs_m, direction = :x, color = :firebrick4)
hline_h = rangebars!(vals_h, lows_h, highs_h, direction = :x, color = :steelblue3)


connect!(line_m.visible, toggle_m.active)
connect!(hline_m.visible, toggle_m.active)
connect!(line_h.visible, toggle_h.active)
connect!(hline_h.visible, toggle_h.active)

ylims!(ax, -100, 1e4)
xlims!(ax, 0, 6)
axislegend(ax)

fig
