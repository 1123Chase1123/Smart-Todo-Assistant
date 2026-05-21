/**
 * Task data model
 * 使用 @Observed 装饰器使所有属性可观察
 */
@Observed
export class Task {
  id: number;
  name: string;
  priority: string;
  isCompleted: boolean;
  createdTime: number;

  constructor(name: string, priority: string = 'medium') {
    this.id = Date.now();
    this.name = name;
    this.priority = priority;
    this.isCompleted = false;
    this.createdTime = Date.now();
  }
}
