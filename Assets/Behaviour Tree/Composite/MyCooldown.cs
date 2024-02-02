using UnityEngine;

namespace BehaviorDesigner.Runtime.Tasks
{
    [TaskDescription("The sequence task is similar to an \"and\" operation. It will return failure as soon as one of its child tasks return failure. " +
                     "If a child task returns success then it will sequentially run the next task. If all child tasks return success then it will return success.")]
    [TaskIcon("{SkinColor}SequenceIcon.png")]
    public class MyCooldown : Composite
    {
        public SharedFloat duration = 2;

        private float cooldownTime = -1;
        
        // The index of the child that is currently running or is about to run.
        private int currentChildIndex = 0;
        // The task status of the last child ran.
        private TaskStatus executionStatus = TaskStatus.Inactive;

        public override int CurrentChildIndex()
        {
            return currentChildIndex;
        }

        public override bool CanExecute()
        {
            if (cooldownTime == -1) {
                return currentChildIndex < children.Count && executionStatus != TaskStatus.Failure;
            }

            if (cooldownTime + duration.Value < Time.time)
                return false;
            
            // We can continue to execuate as long as we have children that haven't been executed and no child has returned failure.
            return currentChildIndex < children.Count && executionStatus != TaskStatus.Failure && cooldownTime + duration.Value > Time.time;
        }

        public override void OnChildExecuted(TaskStatus childStatus)
        {
            // Increase the child index and update the execution status after a child has finished running.
            currentChildIndex++;
            executionStatus = childStatus;
            
            if (executionStatus == TaskStatus.Failure || executionStatus == TaskStatus.Success) {
                cooldownTime = Time.time;
            }
        }

        public override void OnConditionalAbort(int childIndex)
        {
            // Set the current child index to the index that caused the abort
            currentChildIndex = childIndex;
            executionStatus = TaskStatus.Inactive;
        }

        public override void OnEnd()
        {
            cooldownTime = -1;
            
            // All of the children have run. Reset the variables back to their starting values.
            executionStatus = TaskStatus.Inactive;
            currentChildIndex = 0;
        }
        
        public override TaskStatus OverrideStatus()
        {
            if (!CanExecute()) {
                return TaskStatus.Failure;
            }
            return executionStatus;
        }
    }
}