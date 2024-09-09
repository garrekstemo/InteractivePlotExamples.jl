using FFTW
using GLMakie

function damped_sine(t, f, τ)
    return @. sin(2π * f * t) * exp(-t / τ)
end

f = Observable(1.0)
τ = Observable(3.0)
fs = 44100
t = 0:1/fs:10
y1 = @lift(damped_sine(t, $(f), $(τ)))
y2 = damped_sine(t, 2, 1)
combined = @lift($y1 + y2)

Y1 = @lift(abs.(fftshift(fft($(y1)))))
frequencies = fftshift(fftfreq(length(t), fs))

Y_combined = @lift(abs.(fftshift(fft($(combined)))))
frequencies_combined = fftshift(fftfreq(length(t), fs))


# Make the Figure

fig = Figure(size = (900, 500))

ax = Axis(fig[1, 1], ylabel = "Amplitude", xlabel = "Time (s)",
    yticklabelspace = 20.0)
line1 = lines!(t, y1, visible = true)
line2 = lines!(t, combined, color = :firebrick3, visible = false)

ax2 = Axis(fig[1, 2], ylabel = "Amplitude", xlabel = "Frequency (Hz)")
FTline1 = lines!(frequencies, Y1)
FTline2 = lines!(frequencies_combined, Y_combined, color = :firebrick3, visible = false)
xlims!(-12, 12)

sg = SliderGrid(fig[2, 1],
    (label = "Frequency (Hz)", range = 0.1:0.01:10, format = "{:.1f}", startvalue=1),
    (label = "Decay time (s)", range = 0.05:0.1:7, format = "{:.2f}", startvalue=1),
)

sliderobservables = [s.value for s in sg.sliders]
connect!(f, sliderobservables[1])
connect!(τ, sliderobservables[2])

toggles = [Toggle(fig, active = active, tellwidth = false) for active in [true, false]]
labels = [Label(fig, "Variable sine"), Label(fig, "Second sine @ 2 Hz")]

connect!(line1.visible, toggles[1].active)
connect!(line2.visible, toggles[2].active)
connect!(FTline1.visible, toggles[1].active)
connect!(FTline2.visible, toggles[2].active)

fig[2, 2] = grid!(
    hcat(toggles, labels),
    tellwidth = false)

on(f) do _
    autolimits!(ax)
    autolimits!(ax2)
    xlims!(ax2, -12, 12)
end
on(τ) do _
    autolimits!(ax)
    autolimits!(ax2)
    xlims!(ax2, -12, 12)
end

fig