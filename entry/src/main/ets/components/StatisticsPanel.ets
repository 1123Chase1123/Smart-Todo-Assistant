/**
 * 统计面板组件
 * 使用 @Prop 接收父组件传递的任务数组副本
 */
import { Task } from '../model/Task';

@Component
export struct StatisticsPanel {
  @Prop tasks: Task[] = [];

  build() {
    Column() {
      Row() {
        this.statItem(this.tasks.length, '全部', '#666666')
        this.divider()
        this.statItem(this.tasks.filter(t => t.isCompleted).length, '已完成', '#44BB44')
        this.divider()
        this.statItem(this.tasks.filter(t => !t.isCompleted).length, '未完成', '#FF4444')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FAFAFA')
      .justifyContent(FlexAlign.SpaceAround);
    }
    .width('100%')
  }

  @Builder
  statItem(count: number, label: string, color: ResourceColor) {
    Column() {
      Text(count.toString())
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(color);
      Text(label)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 4 });
    }
    .layoutWeight(1)
  }

  @Builder
  divider() {
    Divider()
      .vertical(true)
      .height(40)
      .color('#E0E0E0')
      .strokeWidth(1)
  }
}
