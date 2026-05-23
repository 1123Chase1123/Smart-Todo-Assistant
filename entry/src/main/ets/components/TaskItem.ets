/**
 * 任务列表项组件
 * 使用 @ComponentV2 + @Param 配合 @ObservedV2 实现深度观察
 */
import { Task, Priority } from '../model/Task';

@ComponentV2
export struct TaskItem {
  @Param task!: Task;
  onToggle?: (task: Task) => void;
  onTap?: (task: Task) => void;

  build() {
    Row() {
      Checkbox()
        .select(this.task.isCompleted)
        .onChange((value: boolean) => {
          this.task.isCompleted = value;
          this.onToggle?.(this.task);
        });

      Column() {
        Text(this.task.name)
          .fontSize(16)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .decoration({
            type: this.task.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None
          })
          .fontColor(this.task.isCompleted ? '#999999' : '#333333');
        Text(this.formatTime(this.task.createdTime))
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 });
      }
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start);

      Blank();

      Text(this.priorityLabel())
        .fontSize(12)
        .fontColor(Color.White)
        .backgroundColor(this.priorityColor())
        .borderRadius(10)
        .padding({ left: 10, right: 10, top: 3, bottom: 3 });
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.onTap?.(this.task);
    });
  }

  priorityLabel(): string {
    const map: Record<Priority, string> = { 'high': '高', 'medium': '中', 'low': '低' };
    return map[this.task.priority] || '中';
  }

  priorityColor(): ResourceColor {
    const map: Record<Priority, ResourceColor> = { 'high': '#FF4444', 'medium': '#FFAA00', 'low': '#44BB44' };
    return map[this.task.priority] || '#FFAA00';
  }

  formatTime(timestamp: number): string {
    const d = new Date(timestamp);
    const pad = (n: number) => n.toString().padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
  }
}
