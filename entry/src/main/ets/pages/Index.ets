/**
 * 智能待办事项助手 - 主页面
 * 使用 @Component + @State 装饰器系统
 * 包含增删改查、筛选排序、统计面板、数据持久化
 */
import { Task } from '../model/Task';
import { taskDb } from '../utils/Database';
import { TaskItem } from '../components/TaskItem';
import { StatisticsPanel } from '../components/StatisticsPanel';

@Entry
@Component
struct Index {
  @State tasks: Task[] = [];
  @State filterPriority: string = 'all';
  @State sortAscending: boolean = false;
  @State showStats: boolean = false;
  @State showSheet: boolean = false;
  @State dialogName: string = '';
  @State dialogPriority: string = 'medium';
  private editingTask: Task | null = null;

  aboutToAppear() {
    this.loadData();
  }

  async loadData(): Promise<void> {
    try {
      const ctx = getContext(this);
      await taskDb.init(ctx);
      this.tasks = await taskDb.loadTasks();
    } catch (e) {
      console.error('load error:' + JSON.stringify(e));
    }
  }

  async saveData(): Promise<void> {
    try {
      await taskDb.saveTasks(this.tasks);
    } catch (e) {
      console.error('save error:' + JSON.stringify(e));
    }
  }

  filteredTasks(): Task[] {
    const result = this.filterPriority === 'all'
      ? [...this.tasks]
      : this.tasks.filter(t => t.priority === this.filterPriority);

    result.sort((a: Task, b: Task) => this.sortAscending
      ? a.createdTime - b.createdTime
      : b.createdTime - a.createdTime);

    return result;
  }

  toggleTask(task: Task): void {
    task.isCompleted = !task.isCompleted;
    this.tasks = [...this.tasks];
    this.saveData();
  }

  deleteTask(id: number): void {
    this.tasks = this.tasks.filter(t => t.id !== id);
    this.saveData();
  }

  openAddDialog(): void {
    this.editingTask = null;
    this.dialogName = '';
    this.dialogPriority = 'medium';
    this.showSheet = true;
  }

  openEditDialog(task: Task): void {
    this.editingTask = task;
    this.dialogName = task.name;
    this.dialogPriority = task.priority;
    this.showSheet = true;
  }

  confirmDialog(): void {
    const name = this.dialogName.trim();
    if (!name) {
      return;
    }
    if (name.length > 50) {
      return;
    }

    if (this.editingTask) {
      this.editingTask.name = name;
      this.editingTask.priority = this.dialogPriority;
      this.tasks = [...this.tasks];
    } else {
      const task = new Task(name, this.dialogPriority);
      this.tasks = [task, ...this.tasks];
    }
    this.saveData();
    this.showSheet = false;
  }

  @Builder
  sheetBuilder() {
    Column() {
      Text(this.editingTask ? '编辑任务' : '添加任务')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 16, bottom: 24 });

      TextInput({ placeholder: '任务名称（最多50字）', text: this.dialogName })
        .height(48)
        .fontSize(16)
        .borderRadius(8)
        .backgroundColor('#F5F5F5')
        .padding({ left: 16 })
        .onChange((val: string) => {
          this.dialogName = val;
        })
        .maxLength(50);

      Text('优先级')
        .fontSize(16)
        .margin({ top: 20, bottom: 12 });

      Row() {
        this.priorityBtn('high', '高');
        this.priorityBtn('medium', '中');
        this.priorityBtn('low', '低');
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly);

      Row() {
        Button('取消')
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .borderRadius(8)
          .height(44)
          .layoutWeight(1)
          .onClick(() => {
            this.showSheet = false;
          });

        Button('确定')
          .backgroundColor('#007AFF')
          .fontColor(Color.White)
          .borderRadius(8)
          .height(44)
          .layoutWeight(1)
          .margin({ left: 12 })
          .onClick(() => {
            this.confirmDialog();
          })
      }
      .margin({ top: 24 })
      .width('100%')
    }
    .padding(24)
    .width('100%')
  }

  @Builder
  priorityBtn(value: string, label: string) {
    Button(label)
      .backgroundColor(this.dialogPriority === value ? this.priorityColor(value) : '#F5F5F5')
      .fontColor(this.dialogPriority === value ? Color.White : '#666666')
      .borderRadius(16)
      .height(40)
      .padding({ left: 24, right: 24 })
      .onClick(() => {
        this.dialogPriority = value;
      })
  }

  @Builder
  deleteBtn(task: Task) {
    Button('删除')
      .backgroundColor(Color.Red)
      .fontColor(Color.White)
      .width(80)
      .height('100%')
      .borderRadius(0)
      .onClick(() => {
        this.deleteTask(task.id);
      });
  }

  @Builder
  filterBtn(label: string, value: string) {
    Button(label)
      .backgroundColor(this.filterPriority === value ? '#007AFF' : '#F0F0F0')
      .fontColor(this.filterPriority === value ? Color.White : '#666666')
      .fontSize(14)
      .borderRadius(16)
      .height(32)
      .padding({ left: 16, right: 16 })
      .onClick(() => {
        this.filterPriority = value;
      });
  }

  priorityLabel(priority: string): string {
    const map: Record<string, string> = { 'high': '高', 'medium': '中', 'low': '低' };
    return map[priority] || '中';
  }

  priorityColor(priority: string): ResourceColor {
    const map: Record<string, ResourceColor> = {
      'high': '#FF4444', 'medium': '#FFAA00', 'low': '#44BB44'
    };
    return map[priority] || '#FFAA00';
  }

  build() {
    Column() {
      // ── 标题栏 ──
      Row() {
        Text('待办事项')
          .fontSize(24)
          .fontWeight(FontWeight.Bold);
        Blank();
        Button(this.showStats ? '收起统计' : '统计')
          .fontSize(14)
          .backgroundColor('#007AFF')
          .fontColor(Color.White)
          .borderRadius(16)
          .height(32)
          .onClick(() => {
            this.showStats = !this.showStats;
          });
      }
      .width('100%')
      .padding(16);

      // ── 统计面板 ──
      if (this.showStats) {
        StatisticsPanel({ tasks: this.tasks })
      }

      // ── 筛选与排序 ──
      Row() {
        this.filterBtn('全部', 'all');
        this.filterBtn('高', 'high');
        this.filterBtn('中', 'medium');
        this.filterBtn('低', 'low');
        Blank();
        Button(this.sortAscending ? '最早↑' : '最新↓')
          .fontSize(14)
          .backgroundColor('#F0F0F0')
          .fontColor('#666666')
          .borderRadius(16)
          .height(32)
          .onClick(() => {
            this.sortAscending = !this.sortAscending;
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 });

      // ── 任务列表 / 空状态 ──
      if (this.filteredTasks().length === 0) {
        Column() {
          Text('暂无任务')
            .fontSize(16)
            .fontColor('#CCCCCC');
          Text(this.filterPriority !== 'all' ? '尝试切换筛选条件' : '点击右下角 + 添加任务')
            .fontSize(14)
            .fontColor('#EEEEEE')
            .margin({ top: 8 });
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      } else {
        List() {
          ForEach(this.filteredTasks(), (task: Task) => {
            ListItem() {
              TaskItem({
                task: task,
                onToggle: (t: Task): void => { this.toggleTask(t) },
                onTap: (t: Task): void => { this.openEditDialog(t) }
              })
            }
            .swipeAction({
              end: {
                builder: (): void => {
                  this.deleteBtn(task)
                }
              }
            })
          }, (task: Task) => task.id.toString())
        }
        .layoutWeight(1)
        .width('100%')
      }

      // ── 底部浮动按钮 ──
      Row() {
        Blank();
        Button('+')
          .width(56)
          .height(56)
          .borderRadius(28)
          .backgroundColor('#007AFF')
          .fontSize(30)
          .fontColor(Color.White)
          .shadow({ radius: 8, offsetX: 0, offsetY: 4, color: 'rgba(0,122,255,0.4)' })
          .onClick(() => {
            this.openAddDialog();
          });
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .bindSheet($$this.showSheet, this.sheetBuilder, { height: SheetSize.MEDIUM })
  }
}
