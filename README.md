# ASX Company Information

A Phoenix LiveView application for fetching and displaying ASX company information and market data.

## Features & Architecture

- **Parallel data fetching**: Company info and quote data fetched concurrently using `assign_async` for better performance
- **Modern UI**: Responsive design with DaisyUI skeleton loading states
- **Zoi validation**: Lightweight input validation without Ecto Changeset overhead
- **Decimal types**: Use Decimal for financial precision (optional)
- **Result helpers**: Better handling of result types
- **Error handling**: Immediate feedback with user-friendly flash messages (retries disabled)
- **Extendable design**: Focus on success logic with clean separation

## Quick Start

1. Install dependencies:
   ```bash
   mix setup
   ```

2. Configure API credentials in `.env`:
   ```bash
   API_BASE_URL=your_api_url
   API_KEY=your_api_key
   ```

3. Start the server:
   ```bash
   mix phx.server
   ```

4. Visit `http://localhost:4000`

## Future Considerations

- **Real-time updates**: Timer-based refresh or webhook/push notifications for stock changes
- **GraphQL API**: Potential for single API call returning both company and quote data
- **Supervisor pattern**: Could add supervision for more complex task management

## Technical Notes

- Uses `assign_async` for higher-level task management over raw Task usage
- Parallel fetching improves performance over `Task.await_many`
- Supervisor pattern not needed at current scale
- API designed for extendability with focus on success logic
