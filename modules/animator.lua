local animator = {}

animator.h_flip = nil
animator.jump_count = nil
animator.grounded = nil
animator.isRight = nil

function animator.play_anim(name, direction)
    if direction.x ~= 0 and direction.y == 0 then

        if direction.x > 0 then 
            animator.h_flip = false
        elseif direction.x < 0 then
            animator.h_flip = true
        end
        return hash(name .. "_run")
    elseif direction.y ~= 0 then
        if direction.y > 0 and animator.jump_count == 0 then
            return hash(name .. "_double_jump")
        elseif direction.y > 0 then
            return hash(name .. "_jump")
        elseif direction.y < 0 and animator.grounded then 
            if animator.isRight then
                animator.h_flip = true
            else
                animator.h_flip = false
            end
            return hash(name .. "_wall_jump")
        elseif direction.y < 0 and not animator.grounded then
            return hash(name .. "_fall")
        end
    else
        return hash(name .. "_idle")
    end
end

return animator