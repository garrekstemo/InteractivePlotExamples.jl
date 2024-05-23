using GLMakie

fig = Figure()
ax = Axis(fig[1, 1], xlabel = "nm")

b1 = Button(fig[2, 1][1, 1], label = "wl", tellwidth = false)
b2 = Button(fig[2, 1][1, 3], label = "wn", tellwidth = false)
b3 = Button(fig[2, 1][1, 2], label = "set units", tellwidth = false)

on(b1.clicks) do _
    ax.xlabel = "wl"
end
on(b2.clicks) do _
    ax.xlabel = "wn"
end
on(b3.clicks) do _
    # println(ax.xlabel)
    if to_value(ax.xlabel) == "wl"
        ax.xlabel = "wn"
        b3.label = "wn"
        println(b3.label)
    elseif to_value(ax.xlabel) == "wn"
        ax.xlabel = "wl"
        b3.label = "wl"
    end
end

fig