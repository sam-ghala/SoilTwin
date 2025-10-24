function train_pinn(prob, max_iters::Int)
    opt = LBFGS(linesearch=LineSearches.BackTracking())
    print_every = max(1, div(max_iters, 10))
    iteration = 0
    loss_history = Float64[]
    
    callback = function(p, l)
        iteration += 1
        push!(loss_history, l)

        if iteration % print_every == 0
            println("Iter $iteration | Loss: $(round(l, sigdigits=6)) | ")
        end
        
        if length(loss_history) > 100
            recent_avg = mean(loss_history[end-50:end])
            old_avg = mean(loss_history[end-100:end-51])
            if abs(recent_avg - old_avg) / old_avg < 1e-3
                println("Early stopping: Loss plateaued")
                return true
            end
        end
        
        return false
    end
    
    println("Starting optimization with $(max_iters) max iterations...")
    res = SciMLBase.solve(prob, opt, callback=callback, maxiters=max_iters)
    return res, loss_history
end