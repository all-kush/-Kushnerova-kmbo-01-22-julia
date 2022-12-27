include("FunctionsForRobot.jl")
include("Все_для_задач.jl")
import HorizonSideRobots.move!

#Задача 1 (прямой крест)
function mark_cross!(r::Robot)
    for side in (HorizonSide(i) for i in 0:3)
        n_steps = putmarkers_until_border!(r, side) 
        moves!(r, inverse(side), n_steps)
    end
    putmarker!(r)
end

#Задача 2 (внешняя рамка маркеров)
function mark_perimetr!(r::Robot)
    steps_to_left_down_angle = [0, 0] # (шаги_вниз, шаги_влево)
    steps_to_left_down_angle[1] = move_until_border!(r, Sud)
    steps_to_left_down_angle[2] = move_until_border!(r, Ost)
    for side in (HorizonSide(i) for i in 0:3)
        putmarkers_until_border!(r, side)
    end
    moves!(r, West, steps_to_left_down_angle[2])
    moves!(r, Nord, steps_to_left_down_angle[1])
end

#Задача 3 (все клетки промаркированы)
function mark_fild!(r::Robot)
    steps_to_origin = get_left_down_angle!(r)
    putmarker!(r)
    side=Ost
    putmarkers_until_border!(r,side)
    while !isborder(r, Nord)
        move!(r, Nord)
        putmarker!(r)
        side=inverse(side)
        putmarkers_until_border!(r, side)
    end
    get_left_down_angle!(r)
    get_to_origin!(r, steps_to_origin)
end

#Задача 4 (косой крест)
function X_mark_the_spot!(r::Robot)
    sides = (Nord, Ost, Sud, West)
    for i in 1:4
        first_side = sides[i]
        second_side = sides[i % 4 + 1]
        direction = (first_side, second_side)
        n_steps = putmarkers_until_border!(r, direction)
        moves!(r, inverse_side(direction::NTuple{2, HorizonSide}), n_steps)
    end
    putmarker!(r)
end

#Задача 5 (внешняя рамка маркеров+внешняя рамка маркеров прямоугольника)
function mark_two_rectangle!(r::Robot)
    steps = get_left_down_angle_modified!(r)
    while isborder(r, Sud) && !isborder(r, Ost)
        move_until_border!(r, Nord)
        move!(r, Ost)
        while !isborder(r, Ost) && move_if_possible!(r, Sud) end
    end
    for sides in [(Sud, Ost), (Ost, Nord), (Nord, West), (West, Sud)]
        side_to_move, side_to_border = sides
        while isborder(r, side_to_border)
            putmarker!(r)
            move!(r, side_to_move)
        end
        putmarker!(r)
        move!(r, side_to_border)
    end
    get_right_down_angle_modified!(r)
    frame!(r)
    get_left_down_angle_modified!(r)
    make_way_back!(r, steps)
end

#Задача 6 (поле с перегородками)

# подзадача а (внешняя рамка с маркерами)
function mark_perimetr_with_inner_border!(r::Robot)
    path = get_left_down_angle_modified!(r)
    mark_perimetr!(r)
    make_way_back!(r, path)
end

#подзадача б (маркеры напротив положения робота)
function mark_four_cells!(r::Robot) 
    path = get_left_down_angle_modified!(r)
    n_steps_to_sud = 0
    n_steps_to_west = 0
    for step in path
        if step[1] == Sud
            n_steps_to_sud += step[2]
        else
            n_steps_to_west += step[2]
        end
    end
    moves!(r, Ost, n_steps_to_west)
    putmarker!(r)
    move_until_border!(r, Ost)
    moves!(r, Nord, n_steps_to_sud)
    putmarker!(r)
    get_left_down_angle_modified!(r)
    moves!(r, Nord, n_steps_to_sud)
    putmarker!(r)
    move_until_border!(r, Nord)
    moves!(r, Ost, n_steps_to_west)
    putmarker!(r)
    get_left_down_angle_modified!(r)
    make_way_back!(r, path)
end

#Задача 7 (бесконечная перегородка с проходом > робот под проходом)
function move_through!(r::Robot)
    side=Sud
    find_space!(r, side)
    move!(r, side)
end

#Задача 8 (поле без перегородок, найти маркер)
function move_snake_until_marker!(r::Robot)
    n_steps = 1
    cur_side = Ost
    counter = 1
    while true
        if moves_if_not_marker!(r, cur_side, n_steps)
            return
        end 
        cur_side = next_side(cur_side)
        if counter % 2 == 0
            n_steps += 1
        end

        counter += 1
    end
end

#Задача 9 (маркеры в шахматном порядке, в клетке с роботом маркер)
function mark_chess!(r::Robot)

    steps = get_left_down_angle!(r)
    to_mark = (steps[1] + steps[2]) % 2 == 0
    steps_to_ost_border = move_until_border!(r, Ost)
    move_until_border!(r, West)
    last_side = steps_to_ost_border % 2 == 1 ? Sud : Nord #Сторона, в направлении которой нужно будет
                                                          # идти в конце, так как на Ost будет граница
    side = Nord                                           # ? : это тернарный оператор

    while !isborder(r, Ost)

        while !isborder(r, side)
            if to_mark   #Если to_mark==true, то ставить маркер, чтобы в клетке местоположения он тоже был
                putmarker!(r)
            end

            move!(r, side)
            to_mark = !to_mark
        end

        if to_mark
            putmarker!(r)
        end

        move!(r, Ost)
        to_mark = !to_mark

        side = inverse_side(side)
    end

    while !isborder(r, last_side)

        while !isborder(r, side)
            if to_mark
                putmarker!(r)
            end

            move!(r, side)
            to_mark = !to_mark
        end

        if to_mark
            putmarker!(r)
        end

    end

    get_left_down_angle!(r)
    get_to_origin!(r, steps)
end

#Задача 11 (горизонтальные перегородки > число перегородок) side=Ost
function all_borders!(r,side)
    all=0
    while !isborder(r,Nord)&&(!isborder(r,Ost)|| !isborder(r,West))
        all+= num_borders!(r, side)
        move!(r,Nord)
        side=inverse(side)
    end
    return all
end

#Задача 12 (горизонтальные перегородки > число перегородок (с одной пустой клеткой-все еще перегородка))
#side=Ost
function all_borders2!(r,side)
    all=0
    while !isborder(r,Nord)&&(!isborder(r,Ost)|| !isborder(r,West))
        all+= num_borders2!(r, side)
        move!(r,Nord)
        side=inverse(side)
    end
    return all
end

#Задача 15 (бесконечная перегородка с проходом > робот под проходом (обобщенная функция shatl!))
#side_to_wall=Sud
function find_space!(r::Robot, side_to_wall::HorizonSide)
    n_steps = 1
    side = next_side(side_to_wall)

    while isborder(r, side_to_wall)
        for _ in 1:n_steps
            shatl!( _ -> !isborder(r, side_to_wall), r, side)
        end
        side = inverse_side(side)
        n_steps += 1
    end
    move!(r,side_to_wall)
end

#Задача 16 (поле без перегородок, найти маркер (обобщеннная функция spiral!))
function find_marker!(r::Robot)
    tmp = (side::HorizonSide) -> ismarker(r)
    spiral!( tmp, r)
end

#Задача 18 (робота до упора, рекурсия)
function move_until_border_recursive!(r::Robot, side::HorizonSide)
    if !isborder(r, side)
        move!(r, side)
        move_until_border_recursive!(r, side)
    end
end

#Задача 19 (робота до упора+маркер+обратно, рекурсия)
function putmarker_at_border_and_back!(r::Robot, side::HorizonSide)
    if isborder(r, side)
        putmarker!(r)
    else
        move!(r, side)
        putmarker_at_border_and_back!(r, side)
        move!(r, inverse_side(side))
    end
end

#Задача 20 (соседняя клетка+перегородка, рекурсия)
function obhod_peregorodki!(r, side)
    if !isborder(r, side)
        move!(r, side)
    else
        move!(r, left(side))
        obhod_peregorodki!(r, side)
        move!(r, right(side))
    end
end

#Задача 22 (позиция симметричная к другой перегородке, рекурсия)
function to_symmetric_position!(r, side) #side - с какой стороны другая перегородка
    if isborder(r, side)
        move_until_border_recursive!(r, inverse_side(side))
    else
        move!(r,side)
        to_symmetric_position!(r, side)
        move!(r,side)
    end
end

#Задача 24 (расстоние до перегородки вдвое меньше исходного, косвенная рекурсия)
function polovina_peregorodki!(r, side)
    if !isborder(r, side)
        move!(r, side)
        no_delayed_action!(r, side)
        move!(r, inverse_side(side)) # отложенное действие
    end
end
function no_delayed_action!(r,side)
    if !isborder(r, side)
        move!(r, side)
        polovina_peregorodki!(r, side)
    end
end

#Задача 25 (маркеры в шахматном порядке до упора, косвенная рекурсия)
function mark_chess_rec!(r::Robot, side::HorizonSide, to_mark = true)
    if to_mark
        putmarker!(r)
    end

    if !isborder(r, side)
        move!(r, side)
        to_mark = !to_mark
        mark_chess_rec!(r, side, to_mark)
    end
end

#а (начинать с утановки маркера)
function ::Robot, side::HorizonSide)
    mark_chess_rec!(r, side)
end

#б (начинать с пропуска)
function mark_chess_negative!(r,side)
    mark_chess_rec!(r, side, false)
end

#Задача 26 (значение n-ого члена последовательности Фибоначчи)
#а (без рекурсии)
function get_fibbonachi(n::Int)::Int
    if n == 1 || n == 2
        return 1
    end

    a = 1
    b = 1
    for i in 3:n
        tmp = a + b
        a, b = b, tmp
    end

    return b
end

#б (с рекурсией)
function get_fibbonachi_rec(n::Int)::Int
    if n == 1 || n == 2
        return 1
    end

    return get_fibbonachi_rec(n-1) + get_fibbonachi_rec(n - 2)
end