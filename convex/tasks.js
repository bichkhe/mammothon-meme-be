import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

export const get = query({
  handler: async ({ db }) => {
    return await db.query("tasks").collect();
  },
});

export const create = mutation({
  args: {
    isCompleted: v.boolean(),
    text: v.string(),
  },
  handler: async (ctx, args) => {
    const taskId = await ctx.db.insert("tasks", {
      text: args.text,
      isCompleted: args.isCompleted,
    });
    console.log("create new task: ", taskId);
  },
});
