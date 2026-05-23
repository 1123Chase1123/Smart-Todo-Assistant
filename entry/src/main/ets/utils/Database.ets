/**
 * 数据持久化工具 —— 使用鸿蒙 Preferences API
 * AI生成：将任务列表序列化为 JSON 字符串存储
 * 手动修改：添加了异常处理和类型安全
 */
import { preferences } from '@kit.ArkData';
import { Task, Priority } from '../model/Task';

const PREFERENCES_NAME = 'todo_preferences';
const TASKS_KEY = 'task_list';

interface TaskJson {
  id: number;
  name: string;
  priority: Priority;
  isCompleted: boolean;
  createdTime: number;
}

class TaskDatabase {
  private store: preferences.Preferences | null = null;

  async init(context: Context): Promise<void> {
    this.store = await preferences.getPreferences(context, PREFERENCES_NAME);
  }

  async loadTasks(): Promise<Task[]> {
    if (!this.store) return [];
    try {
      const value = await this.store.get(TASKS_KEY, '[]');
      const jsonStr: string = value as string;
      const arr: TaskJson[] = JSON.parse(jsonStr);
      return arr.map(item => {
        const task = new Task(item.name, item.priority);
        task.id = item.id;
        task.isCompleted = item.isCompleted;
        task.createdTime = item.createdTime;
        return task;
      }) as Task[];
    } catch (e) {
      console.error('Failed to load tasks:', JSON.stringify(e));
      return [];
    }
  }

  async saveTasks(tasks: Task[]): Promise<void> {
    if (!this.store) return;
    const data: TaskJson[] = tasks.map(t => {
      const item: TaskJson = {
        id: t.id,
        name: t.name,
        priority: t.priority,
        isCompleted: t.isCompleted,
        createdTime: t.createdTime
      };
      return item;
    });
    await this.store.put(TASKS_KEY, JSON.stringify(data));
    await this.store.flush();
  }
}

export const taskDb = new TaskDatabase();
