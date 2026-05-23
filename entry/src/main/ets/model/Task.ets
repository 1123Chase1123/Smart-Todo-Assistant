/**
 * Task data model
 * 使用 @ObservedV2 + @Trace 实现属性级深度观察
 */
export type Priority = 'high' | 'medium' | 'low';
@ObservedV2
export class Task {
  @Trace id: number = 0;
  @Trace name: string = '';
  @Trace priority: Priority = 'medium';
  @Trace isCompleted: boolean = false;
  @Trace createdTime: number = 0;

  constructor(name: string, priority: Priority = 'medium') {
    this.id = Date.now();
    this.name = name;
    this.priority = priority;
    this.isCompleted = false;
    this.createdTime = Date.now();
  }
}
