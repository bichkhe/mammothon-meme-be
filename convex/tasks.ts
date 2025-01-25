import { query, mutation } from "./_generated/server";
import { v } from "convex/values";

export const get = query({
  args: {
    queryFilter: v.optional(
      v.object({
        is_completed: v.optional(v.boolean()),
        text: v.optional(v.string()),
      }),
    ),
    pagination: v.optional(
      v.object({ limit: v.number(), cursor: v.optional(v.string()) }),
    ),
  },
  handler: async (ctx, args) => {
    let query = ctx.db.query("tasks");
    query = buildFilter(query, args);

    if (args.pagination) {
      return await query.paginate({
        numItems: args.pagination.limit,
        cursor: args.pagination.cursor,
      });
    } else {
      return await query.paginate({ numItems: 10, cursor: null });
    }
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

const buildFilter = (query, args) => {
  if (!args) {
    return;
  }
  if (args.queryFilter) {
    if (args.queryFilter.is_completed !== undefined) {
      query = query.filter((q) =>
        q.eq(q.field("isCompleted"), args.queryFilter.is_completed),
      );
    }
    if (args.queryFilter.text !== undefined) {
      query = query.filter((q) => q.eq(q.field("text"), args.queryFilter.text));
    }
  }
  return query;
};
