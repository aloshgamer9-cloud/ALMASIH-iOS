
export default {
  async fetch(request, env) {
    const headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store"
    };

    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/health") {
      return new Response(
        JSON.stringify({
          status: "online",
          service: "ALMASIH Backend",
          version: "1.0.0"
        }),
        { status: 200, headers }
      );
    }

    return new Response(
      JSON.stringify({
        error: "Route not found"
      }),
      { status: 404, headers }
    );
  }
};
