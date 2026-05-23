/**
 * 统计面板组件
 * 使用 @ComponentV2 + @Param 接收父组件传递的任务数组
 */
import { Task } from '../model/Task';

@ComponentV2
export struct StatisticsPanel {
  @Param tasks: Task[] = [];

  build() {
  const total = this.tasks.length;
  const completed = this.tasks.filter(t => t.isCompleted).length;
  const pending = total - completed;
  const rate = total === 0 ? 0 : Math.round(completed * 100 / total);

  Column() {
    Row() {
      this.statItem(total, '全部', '#666666')
      this.divider()
      this.statItem(completed, '已完成', '#44BB44')
      this.divider()
      this.statItem(pending, '未完成', '#FF4444')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FAFAFA')
    .justifyContent(FlexAlign.SpaceAround);

    Text(`完成率 ${rate}%`)
      .fontSize(13)
      .fontColor('#666666')
      .margin({ top: 8, bottom: 12 })
      .width('100%')
      .textAlign(TextAlign.Center);
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
