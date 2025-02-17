function livepanel(towatch, file_ext=".csv")
    if isdir(towatch)
        towatch = abspath(towatch)
    end

    fig = Figure()
    display(fig)
    DataInspector(fig)

    xlive, ylive = Observable(rand(1)), Observable(rand(1))

    axlive = Axis(fig[1, 1], title = "Put files from 'device' into 'output' folder")
    lines!(xlive, ylive, color = :firebrick4)
    text!(" • Live", color = :red, space = :relative, align = (:left, :bottom))

    # Watch for new data
    while true
        (file, event) = watch_folder(towatch)

        if endswith(file, file_ext)

            # Windows has this for some reason
            if findfirst('\\', file) == 1
                file = file[2:end]
            end
            println("New file: ", file)

            df = DataFrame(CSV.File(joinpath(towatch, file)))
            xlabel, ylabel = propertynames(df)
            xlive.val = df[!, 1]
            ylive[] = df[!, 2]

            axlive.title = chop(file, tail=4)
            axlive.xlabel = string(xlabel)
            axlive.ylabel = string(ylabel)
            autolimits!(axlive)
        end
    end

end