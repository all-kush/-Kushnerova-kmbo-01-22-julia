function cross!(robot)
    for side in (HorizonSide(i) for i in 0:3) #генератор
        n=numsteps_putmarkers!(robot,side)
        along!(robot, inverse(side), n)
    end
    putmarker!(robot)
end
function numsteps_putmarkers!(robot,side)
    num_steps=0
    while !isborder(robot,side)
        move!(robot,side)
        num_steps+=1
        putmarker!(robot)
    end
    return num_steps
end
inverse(side::HorizonSide)=HorizonSide(mod(Int(side)+2, 4))
function along!(robot,side,n)
    for _ in 1:n
        move!(robot,side)
    end
end