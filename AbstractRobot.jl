using HorizonSideRobots
HSR=HorizonSideRobots

mutable struct Coordinates
    x::Int
    y::Int
end

mutable struct AbstractRobot 
    robot::Robot
    direct::HorizonSide
    coord::Coordinates
    right_c::Int
    left_c::Int
end

function around!(r::AbstractRobot)
    d = direction(robot)
    while true
        if HSR.isborder(robot,left)
            if !HSR.isborder(robot,something)
                forward!(robot)
            else
                count_turn!(robot,right)
            end
        else
            count_turn!(robot,left)
            forward!(robot)
        end
        if is_start(robot,d)
            break
        end
    end
end

function is_in_lab(robot::AbstractRobot)
    if robot.right_c<robot.left_c
        print("OUT")
    else
        print("IN")
    end
end

function direction(robot::AbstractRobot)
    while (!HSR.isborder(robot,left) || !HSR.isborder(robot,something))
        turn!(robot,left)
    end 
    return get_direct(robot)
end

function forward!(robot::AbstractRobot) 
    move!(robot.robot, robot.direct)
    direction = get_direct(robot)
    HorizonSideRobots.move!(robot,direction)
end

function is_start(robot::AbstractRobot,direction) 
    return robot.coord.x==robot.coord.y==0 && get_direct(robot)==direction
end

function turn!(robot::AbstractRobot, direct)
    robot.direct = direct(robot.direct)
end

function count_turn!(robot::AbstractRobot,direct)
    if direct == left
        robot.left_c+=1
    elseif direct == right
        robot.right_c+=1
    end
    robot.direct = direct(robot.direct)
end

function HorizonSideRobots.move!(robot::AbstractRobot, side::HorizonSide)
    if side==Nord
        robot.coord.y += 1
    elseif side==Sud
        robot.coord.y -= 1
    elseif side==Ost
        robot.coord.x += 1
    else
        robot.coord.x -= 1
    end
end

HSR.isborder(robot::AbstractRobot,direct)=isborder(robot.robot,direct(robot.direct))

HSR.putmarker!(robot::AbstractRobot) = putmarker!(robot.robot)

HSR.ismarker(robot::AbstractRobot) = ismarker(robot.robot)

get_direct(robot::AbstractRobot) = robot.direct


function inverse(side::HorizonSide)::HorizonSide
    if side == Nord
        return Sud
    elseif side == Sud
        return Nord
    elseif side == Ost
        return West
    else 
        return Ost
    end
end

right(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)-1, 4))
left(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+1, 4))


function answer!(robot)
    around!(robot)
    is_in_lab(robot)
end

robot = AbstractRobot(Robot("untitled.sit", animate = true), Nord, Coordinates(0, 0),0,0)
answer!(robot)