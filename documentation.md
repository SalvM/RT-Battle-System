# Documentation
In this document you will find all the logics used easily explained

## Hero2
The KB has multiple collisions all stored into the *HurtBox* Area2D.
In order to make the body collision works the KB needs at least one ad direct child.
So with the new scripts the main collision box will change after each animation.
It will be literally replaced in *changeHurtBoxCollision*.
With the *AnimationPlayer* we can easily create a complex composition of sprites, collisions and sound effects;
so the hit will be triggered at the exact moment we want.