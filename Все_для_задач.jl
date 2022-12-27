function inverse_side(side::HorizonSide)::HorizonSide #Меняет сторону на противоположную
    inv_side = HorizonSide((Int(side) + 2) % 4)
    return inv_side
end
function move_until_border!(r::Robot, side::HorizonSide) #Двигаться, пока нет стенки+считает шаги
    n_steps = 0
    while !isborder(r, side)
        n_steps += 1
        move!(r, side)
    end
    return n_steps
end
function moves!(r::Robot, side::HorizonSide, n_steps::Int) #Двигаться на определенное количество шагов
    for i in 1:n_steps
        move!(r, side)
    end
end
function putmarkers_until_border!(r::Robot, side::HorizonSide) #Ставит маркеры + Возвращает кол-во шагов до перегородки
    n_steps = 0
    while !isborder(r, side) 
        move!(r, side)
        putmarker!(r)
        n_steps += 1
    end 
    return n_steps
end
inverse(side::HorizonSide)=HorizonSide(mod(Int(side)+2, 4)) #Меняет сторону на противоположную

function get_left_down_angle!(r::Robot)::NTuple{2, Int}# перемещает робота в нижний левый угол, возвращает количество шагов
    steps_to_left_border = move_until_border!(r, West)
    steps_to_down_border = move_until_border!(r, Sud)
    return (steps_to_down_border, steps_to_left_border)
end
function get_to_origin!(r::Robot, steps_to_origin::NTuple{2, Int}) #Перемещает робота в первоначальное положение
    for (i, side) in enumerate((Nord, Ost))
        moves!(r, side, steps_to_origin[i])
    end
end

function putmarkers_until_border!(r::Robot, sides::NTuple{2, HorizonSide})::Int #Ставит маркеры наискосок до границы 
    n_steps = 0
    while !isborder(r, sides[1]) && !isborder(r, sides[2])
        n_steps += 1
        move!(r, sides)
        putmarker!(r)
    end
    return n_steps
end
function moves!(r::Robot, sides::NTuple{2, HorizonSide}, n_steps::Int)#Двигает робота в две стороны поочередно n раз
    for _ in 1:n_steps
        move!(r, sides)
    end
end
function move!(r::Robot, sides::NTuple{2, HorizonSide}) #Двигает робота в две стороны поочередно
    for side in sides
        move!(r, side)
    end
end
function inverse_side(sides::NTuple{2, HorizonSide}) #Меняет две стороны на противоположные
    new_sides = (inverse_side(sides[1]), inverse_side(sides[2]))
    return new_sides
end
#Перемещает робота в правый нижний угол и возвращает шаги вправо и вниз
function get_right_down_angle_modified!(r::Robot)::Vector{Tuple{HorizonSide, Int}} 
    steps = []
    while !(isborder(r, Ost) && isborder(r, Sud))
        steps_to_Ost = move_until_border!(r, Ost)
        steps_to_Sud = move_until_border!(r, Sud)
        push!(steps, (Ost, steps_to_Ost))
        push!(steps, (Sud, steps_to_Sud))
    end
    return steps
end
#Перемещает робота в левый нижний угол и возвращает шаги влево и вниз
function get_left_down_angle_modified!(r::Robot)::Vector{Tuple{HorizonSide, Int}}
    steps = []
    while !(isborder(r, West) && isborder(r, Sud))
        steps_to_West = move_until_border!(r, West)
        steps_to_Sud = move_until_border!(r, Sud)
        push!(steps, (West, steps_to_West))
        push!(steps, (Sud, steps_to_Sud))
    end
    return steps
end
# Если нет перегородки двигайся и возвращай true, иначе false
function move_if_possible!(r::Robot, side::HorizonSide)::Bool
    if !isborder(r, side)
        move!(r, side)
        return true
    end
    return false
end
#(для возвращения на место)меняет стороны на противоположные
function inversed_path(path::Vector{Tuple{HorizonSide, Int}})::Vector{Tuple{HorizonSide, Int}}
    inv_path = []
    for step in path
        inv_step = (inverse_side(step[1]), step[2])
        push!(inv_path, inv_step)
    end
    reverse!(inv_path)#меняет местами последовательность сторон
    return inv_path
end
#двигает робота на сколько-то шагов поочередно
function make_way!(r::Robot, path::Vector{Tuple{HorizonSide, Int}})
    for step in path
        moves!(r, step[1], step[2])
    end
end
#двигает робота обратно на сколько-то шагов поочередно
function make_way_back!(r::Robot, path::Vector{Tuple{HorizonSide, Int}})
    inv_path = inversed_path(path)
    make_way!(r, inv_path)
end
function frame!(r) #Делает рамку
    for side in (HorizonSide(i) for i in 0:3)
        along!(r,side)
    end
end
function along!(r,side) #Пока нет перегородки двигается и ставит маркеры
    while !isborder(r,side)
        move!(r,side)
        putmarker!(r)
    end
end

function moves_if_possible!(r::Robot, side::HorizonSide, n_steps::Int)::Bool #Если возможно двигает робота на n шагов
    
    while n_steps > 0 && move_if_possible!(r, side)
        n_steps -= 1
    end
    if n_steps == 0
        return true
    end
    return false
end

function find_space!(r::Robot, side::HorizonSide) #ищет пустое пространство
    n_steps = 1
    ort_side = HorizonSide((Int(side) + 1) % 4)
    while isborder(r, side)
        moves!(r, ort_side, n_steps)
        n_steps += 1
        ort_side = inverse_side(ort_side)
    end
end
#двигает робота на шаг, пока не нашелся маркер
function move_if_not_marker!(r::Robot, side::HorizonSide)::Bool
    
    if !ismarker(r)
        move!(r, side)
        return false
    end
    return true
end
#двигает робота на n шагов, пока не нашелся маркер
function moves_if_not_marker!(r::Robot, side::HorizonSide, n_steps::Int)::Bool
    for _ in 1:n_steps
        if move_if_not_marker!(r, side)
            return true
        end
    end
    
    return false
end
#Меняет сторону на следующую (Nord, West, Sud, Ost)
function next_side(side::HorizonSide)::HorizonSide
    return HorizonSide( (Int(side) + 1 ) % 4 )
end

function mark_square!(r::Robot, n::Int)

    counter1 = 1
    counter2 = 1

    while counter1 <= n && !isborder(r, Ost)

        while counter2 < n && !isborder(r, Nord)
            putmarker!(r)
            move!(r, Nord)
            counter2 += 1
        end

        putmarker!(r)
        moves!(r, Sud, counter2 - 1)
        counter2 = 1

        move!(r, Ost)
        counter1 += 1
    end

    if isborder(r, Ost) && counter1 <= n
        while counter2 < n && !isborder(r, Nord)
            putmarker!(r)
            move!(r, Nord)
            counter2 += 1
        end

        putmarker!(r)
        moves!(r, Sud, counter2 - 1)
    end

    moves!(r, West, counter1 - 1)
end

function moves_if_possible_numeric!(r::Robot, side::HorizonSide, n_steps::Int)::Int

    while n_steps > 0 && move_if_possible!(r, side)
        n_steps -= 1
    end

    return n_steps
end

function num_borders!(r, side) #Считает число перегородок в ряду
    state = 0
    num_borders = 0
    while try_move!(r, side)
        if state == 0
            if isborder(r, Nord)
                state = 1
            end
        else
            if !isborder(r, Nord)
                state = 0
                num_borders += 1
            end
        end
    end
    return num_borders
end

function try_move!(r, side)::Bool
    if isborder(r, side)
        return false
    end
    move!(r, side)
    return true
end

function num_borders2!(robot, side) #Считает число перегородок в ряду (перегородка может быть с одинарным разрывом)
    state = 0 
    num_borders = 0
    while try_move!(robot, side)
        if state == 0
            if isborder(robot, Nord)
                state = 1
            end
        elseif state == 1
            if !isborder(robot, Nord)
                state = 2
            end
        else
            if !isborder(robot, Nord)
                state = 0
                num_borders += 1
            end
        end
    end
    return num_borders
end

